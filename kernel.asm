
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
8010002d:	b8 c2 3a 10 80       	mov    $0x80103ac2,%eax
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
8010003a:	c7 44 24 04 ac 98 10 	movl   $0x801098ac,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100049:	e8 50 54 00 00       	call   8010549e <initlock>

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
80100087:	c7 44 24 04 b3 98 10 	movl   $0x801098b3,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 c9 52 00 00       	call   80105360 <initsleeplock>
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
801000c9:	e8 f1 53 00 00       	call   801054bf <acquire>

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
80100104:	e8 20 54 00 00       	call   80105529 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 83 52 00 00       	call   8010539a <acquiresleep>
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
8010017d:	e8 a7 53 00 00       	call   80105529 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 0a 52 00 00       	call   8010539a <acquiresleep>
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
801001a7:	c7 04 24 ba 98 10 80 	movl   $0x801098ba,(%esp)
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
801001fb:	e8 37 52 00 00       	call   80105437 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 cb 98 10 80 	movl   $0x801098cb,(%esp)
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
8010023b:	e8 f7 51 00 00       	call   80105437 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 d2 98 10 80 	movl   $0x801098d2,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 97 51 00 00       	call   801053f5 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100265:	e8 55 52 00 00       	call   801054bf <acquire>
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
801002d1:	e8 53 52 00 00       	call   80105529 <release>
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
801003dc:	e8 de 50 00 00       	call   801054bf <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 d9 98 10 80 	movl   $0x801098d9,(%esp)
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
801004cf:	c7 45 ec e2 98 10 80 	movl   $0x801098e2,-0x14(%ebp)
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
8010054d:	e8 d7 4f 00 00       	call   80105529 <release>
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
80100569:	e8 27 2d 00 00       	call   80103295 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 e9 98 10 80 	movl   $0x801098e9,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 fd 98 10 80 	movl   $0x801098fd,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 cf 4f 00 00       	call   80105576 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 ff 98 10 80 	movl   $0x801098ff,(%esp)
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
80100695:	c7 04 24 03 99 10 80 	movl   $0x80109903,(%esp)
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
801006c9:	e8 1d 51 00 00       	call   801057eb <memmove>
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
801006f8:	e8 25 50 00 00       	call   80105722 <memset>
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
8010078e:	e8 bd 6f 00 00       	call   80107750 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 b1 6f 00 00       	call   80107750 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 a5 6f 00 00       	call   80107750 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 98 6f 00 00       	call   80107750 <uartputc>
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
80100813:	e8 a7 4c 00 00       	call   801054bf <acquire>
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
80100a00:	e8 62 44 00 00       	call   80104e67 <wakeup>
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
80100a21:	e8 03 4b 00 00       	call   80105529 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 16 99 10 80 	movl   $0x80109916,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 d0 44 00 00       	call   80104f0d <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 2e 99 10 80 	movl   $0x8010992e,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 48 99 10 80 	movl   $0x80109948,(%esp)
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
80100a8a:	e8 30 4a 00 00       	call   801054bf <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 44 3a 00 00       	call   801044df <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100aa9:	e8 7b 4a 00 00       	call   80105529 <release>
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
80100ad2:	e8 b9 42 00 00       	call   80104d90 <sleep>

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
80100b5c:	e8 c8 49 00 00       	call   80105529 <release>
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
80100ba2:	e8 18 49 00 00       	call   801054bf <acquire>
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
80100bda:	e8 4a 49 00 00       	call   80105529 <release>
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
80100bf5:	c7 44 24 04 61 99 10 	movl   $0x80109961,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100c04:	e8 95 48 00 00       	call   8010549e <initlock>

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
80100c49:	e8 91 38 00 00       	call   801044df <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 89 2b 00 00       	call   801037df <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 f7 1a 00 00       	call   80102758 <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 f2 2b 00 00       	call   80103861 <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 69 99 10 80 	movl   $0x80109969,(%esp)
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
80100cd8:	e8 55 7a 00 00       	call   80108732 <setupkvm>
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
80100d96:	e8 63 7d 00 00       	call   80108afe <allocuvm>
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
80100de8:	e8 2e 7c 00 00       	call   80108a1b <loaduvm>
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
80100e1f:	e8 3d 2a 00 00       	call   80103861 <end_op>
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
80100e54:	e8 a5 7c 00 00       	call   80108afe <allocuvm>
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
80100e79:	e8 f0 7e 00 00       	call   80108d6e <clearpteu>
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
80100eaf:	e8 c1 4a 00 00       	call   80105975 <strlen>
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
80100ed6:	e8 9a 4a 00 00       	call   80105975 <strlen>
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
80100f04:	e8 1d 80 00 00       	call   80108f26 <copyout>
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
80100fa8:	e8 79 7f 00 00       	call   80108f26 <copyout>
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
80100ff8:	e8 31 49 00 00       	call   8010592e <safestrcpy>

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
80101038:	e8 cf 77 00 00       	call   8010880c <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 90 7c 00 00       	call   80108cd8 <freevm>
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
8010105b:	e8 78 7c 00 00       	call   80108cd8 <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 50 0c 00 00       	call   80101cc1 <iunlockput>
    end_op();
80101071:	e8 eb 27 00 00       	call   80103861 <end_op>
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
801010ec:	c7 44 24 04 75 99 10 	movl   $0x80109975,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801010fb:	e8 9e 43 00 00       	call   8010549e <initlock>
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
8010110f:	e8 ab 43 00 00       	call   801054bf <acquire>
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
80101138:	e8 ec 43 00 00       	call   80105529 <release>
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
80101156:	e8 ce 43 00 00       	call   80105529 <release>
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
8010116f:	e8 4b 43 00 00       	call   801054bf <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 7c 99 10 80 	movl   $0x8010997c,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011a0:	e8 84 43 00 00       	call   80105529 <release>
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
801011ba:	e8 00 43 00 00       	call   801054bf <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 84 99 10 80 	movl   $0x80109984,(%esp)
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
801011f5:	e8 2f 43 00 00       	call   80105529 <release>
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
8010122b:	e8 f9 42 00 00       	call   80105529 <release>

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
80101248:	e8 2a 2f 00 00       	call   80104177 <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 83 25 00 00       	call   801037df <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 a9 09 00 00       	call   80101c10 <iput>
    end_op();
80101267:	e8 f5 25 00 00       	call   80103861 <end_op>
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
801012fe:	e8 f2 2f 00 00       	call   801042f5 <piperead>
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
80101370:	c7 04 24 8e 99 10 80 	movl   $0x8010998e,(%esp)
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
801013ba:	e8 4a 2e 00 00       	call   80104209 <pipewrite>
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
80101400:	e8 da 23 00 00       	call   801037df <begin_op>
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
80101466:	e8 f6 23 00 00       	call   80103861 <end_op>

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
8010147b:	c7 04 24 97 99 10 80 	movl   $0x80109997,(%esp)
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
801014ad:	c7 04 24 a7 99 10 80 	movl   $0x801099a7,(%esp)
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
801014f4:	e8 f2 42 00 00       	call   801057eb <memmove>
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
8010153a:	e8 e3 41 00 00       	call   80105722 <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 99 24 00 00       	call   801039e3 <log_write>
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
8010160d:	e8 d1 23 00 00       	call   801039e3 <log_write>
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
80101683:	c7 04 24 b4 99 10 80 	movl   $0x801099b4,(%esp)
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
80101713:	c7 04 24 ca 99 10 80 	movl   $0x801099ca,(%esp)
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
80101749:	e8 95 22 00 00       	call   801039e3 <log_write>
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
8010176b:	c7 44 24 04 dd 99 10 	movl   $0x801099dd,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
8010177a:	e8 1f 3d 00 00       	call   8010549e <initlock>
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
801017a0:	c7 44 24 04 e4 99 10 	movl   $0x801099e4,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 b0 3b 00 00       	call   80105360 <initsleeplock>
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
80101819:	c7 04 24 ec 99 10 80 	movl   $0x801099ec,(%esp)
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
8010189b:	e8 82 3e 00 00       	call   80105722 <memset>
      dip->type = type;
801018a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801018a6:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ac:	89 04 24             	mov    %eax,(%esp)
801018af:	e8 2f 21 00 00       	call   801039e3 <log_write>
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
801018f1:	c7 04 24 3f 9a 10 80 	movl   $0x80109a3f,(%esp)
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
8010199e:	e8 48 3e 00 00       	call   801057eb <memmove>
  log_write(bp);
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	89 04 24             	mov    %eax,(%esp)
801019a9:	e8 35 20 00 00       	call   801039e3 <log_write>
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
801019c8:	e8 f2 3a 00 00       	call   801054bf <acquire>

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
80101a12:	e8 12 3b 00 00       	call   80105529 <release>
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
80101a48:	c7 04 24 51 9a 10 80 	movl   $0x80109a51,(%esp)
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
80101a86:	e8 9e 3a 00 00       	call   80105529 <release>

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
80101a9d:	e8 1d 3a 00 00       	call   801054bf <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101ab8:	e8 6c 3a 00 00       	call   80105529 <release>
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
80101ad8:	c7 04 24 61 9a 10 80 	movl   $0x80109a61,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 a8 38 00 00       	call   8010539a <acquiresleep>

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
80101b99:	e8 4d 3c 00 00       	call   801057eb <memmove>
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
80101bbe:	c7 04 24 67 9a 10 80 	movl   $0x80109a67,(%esp)
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
80101be1:	e8 51 38 00 00       	call   80105437 <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 76 9a 10 80 	movl   $0x80109a76,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 e7 37 00 00       	call   801053f5 <releasesleep>
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
80101c1f:	e8 76 37 00 00       	call   8010539a <acquiresleep>
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
80101c41:	e8 79 38 00 00       	call   801054bf <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c56:	e8 ce 38 00 00       	call   80105529 <release>
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
80101c93:	e8 5d 37 00 00       	call   801053f5 <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c9f:	e8 1b 38 00 00       	call   801054bf <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101cba:	e8 6a 38 00 00       	call   80105529 <release>
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
80101dcb:	e8 13 1c 00 00       	call   801039e3 <log_write>
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
80101de0:	c7 04 24 7e 9a 10 80 	movl   $0x80109a7e,(%esp)
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
8010208a:	e8 5c 37 00 00       	call   801057eb <memmove>
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
801020c3:	e8 17 24 00 00       	call   801044df <myproc>
801020c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801020ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int x = find(cont->name); // should be in range of 0-MAX_CONTAINERS to be utilized
801020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d4:	83 c0 18             	add    $0x18,%eax
801020d7:	89 04 24             	mov    %eax,(%esp)
801020da:	e8 8c 70 00 00       	call   8010916b <find>
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
8010211a:	c7 04 24 91 9a 10 80 	movl   $0x80109a91,(%esp)
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
8010218b:	c7 04 24 98 9a 10 80 	movl   $0x80109a98,(%esp)
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
80102220:	e8 c6 35 00 00       	call   801057eb <memmove>
    log_write(bp);
80102225:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102228:	89 04 24             	mov    %eax,(%esp)
8010222b:	e8 b3 17 00 00       	call   801039e3 <log_write>
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
80102266:	c7 04 24 9f 9a 10 80 	movl   $0x80109a9f,(%esp)
8010226d:	e8 4f e1 ff ff       	call   801003c1 <cprintf>
    if(tot == 1){
80102272:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102276:	75 13                	jne    8010228b <writei+0x1ce>
      set_curr_disk(1, x);
80102278:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010227b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010227f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102286:	e8 75 72 00 00       	call   80109500 <set_curr_disk>
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
801022d0:	e8 b5 35 00 00       	call   8010588a <strncmp>
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
801022e9:	c7 04 24 a3 9a 10 80 	movl   $0x80109aa3,(%esp)
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
80102327:	c7 04 24 b5 9a 10 80 	movl   $0x80109ab5,(%esp)
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
8010240a:	c7 04 24 c4 9a 10 80 	movl   $0x80109ac4,(%esp)
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
8010244e:	e8 85 34 00 00       	call   801058d8 <strncpy>
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
80102480:	c7 04 24 d1 9a 10 80 	movl   $0x80109ad1,(%esp)
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
801024ff:	e8 e7 32 00 00       	call   801057eb <memmove>
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
8010251a:	e8 cc 32 00 00       	call   801057eb <memmove>
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
8010259d:	e8 3d 1f 00 00       	call   801044df <myproc>
801025a2:	8b 40 68             	mov    0x68(%eax),%eax
801025a5:	89 04 24             	mov    %eax,(%esp)
801025a8:	e8 e3 f4 ff ff       	call   80101a90 <idup>
801025ad:	89 45 f4             	mov    %eax,-0xc(%ebp)

  struct proc* p = myproc();
801025b0:	e8 2a 1f 00 00       	call   801044df <myproc>
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
801025d9:	c7 44 24 04 d9 9a 10 	movl   $0x80109ad9,0x4(%esp)
801025e0:	80 
801025e1:	8b 45 08             	mov    0x8(%ebp),%eax
801025e4:	89 04 24             	mov    %eax,(%esp)
801025e7:	e8 9e 32 00 00       	call   8010588a <strncmp>
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
8010264a:	c7 44 24 04 d9 9a 10 	movl   $0x80109ad9,0x4(%esp)
80102651:	80 
80102652:	8b 45 08             	mov    0x8(%ebp),%eax
80102655:	89 04 24             	mov    %eax,(%esp)
80102658:	e8 2d 32 00 00       	call   8010588a <strncmp>
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
80102867:	c7 44 24 04 dc 9a 10 	movl   $0x80109adc,0x4(%esp)
8010286e:	80 
8010286f:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102876:	e8 23 2c 00 00       	call   8010549e <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010287b:	a1 20 62 11 80       	mov    0x80116220,%eax
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
80102904:	c7 04 24 e0 9a 10 80 	movl   $0x80109ae0,(%esp)
8010290b:	e8 44 dc ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102910:	8b 45 08             	mov    0x8(%ebp),%eax
80102913:	8b 40 08             	mov    0x8(%eax),%eax
80102916:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
8010291b:	76 0c                	jbe    80102929 <idestart+0x31>
    panic("incorrect blockno");
8010291d:	c7 04 24 e9 9a 10 80 	movl   $0x80109ae9,(%esp)
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
8010296f:	c7 04 24 e0 9a 10 80 	movl   $0x80109ae0,(%esp)
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
80102a8f:	e8 2b 2a 00 00       	call   801054bf <acquire>

  if((b = idequeue) == 0){
80102a94:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102a99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102aa0:	75 11                	jne    80102ab3 <ideintr+0x31>
    release(&idelock);
80102aa2:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102aa9:	e8 7b 2a 00 00       	call   80105529 <release>
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
80102b1c:	e8 46 23 00 00       	call   80104e67 <wakeup>

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
80102b3e:	e8 e6 29 00 00       	call   80105529 <release>
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
80102b54:	e8 de 28 00 00       	call   80105437 <holdingsleep>
80102b59:	85 c0                	test   %eax,%eax
80102b5b:	75 0c                	jne    80102b69 <iderw+0x24>
    panic("iderw: buf not locked");
80102b5d:	c7 04 24 fb 9a 10 80 	movl   $0x80109afb,(%esp)
80102b64:	e8 eb d9 ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b69:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6c:	8b 00                	mov    (%eax),%eax
80102b6e:	83 e0 06             	and    $0x6,%eax
80102b71:	83 f8 02             	cmp    $0x2,%eax
80102b74:	75 0c                	jne    80102b82 <iderw+0x3d>
    panic("iderw: nothing to do");
80102b76:	c7 04 24 11 9b 10 80 	movl   $0x80109b11,(%esp)
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
80102b95:	c7 04 24 26 9b 10 80 	movl   $0x80109b26,(%esp)
80102b9c:	e8 b3 d9 ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102ba1:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102ba8:	e8 12 29 00 00       	call   801054bf <acquire>

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
80102c03:	e8 88 21 00 00       	call   80104d90 <sleep>
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
80102c1c:	e8 08 29 00 00       	call   80105529 <release>
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
80102c8e:	a0 80 5c 11 80       	mov    0x80115c80,%al
80102c93:	0f b6 c0             	movzbl %al,%eax
80102c96:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c99:	74 0c                	je     80102ca7 <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c9b:	c7 04 24 44 9b 10 80 	movl   $0x80109b44,(%esp)
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
80102d3e:	c7 44 24 04 76 9b 10 	movl   $0x80109b76,0x4(%esp)
80102d45:	80 
80102d46:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102d4d:	e8 4c 27 00 00       	call   8010549e <initlock>
  kmem.use_lock = 0;
80102d52:	c7 05 94 5b 11 80 00 	movl   $0x0,0x80115b94
80102d59:	00 00 00 
  freerange(vstart, vend);
80102d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d63:	8b 45 08             	mov    0x8(%ebp),%eax
80102d66:	89 04 24             	mov    %eax,(%esp)
80102d69:	e8 26 00 00 00       	call   80102d94 <freerange>
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
80102d83:	e8 0c 00 00 00       	call   80102d94 <freerange>
  kmem.use_lock = 1;
80102d88:	c7 05 94 5b 11 80 01 	movl   $0x1,0x80115b94
80102d8f:	00 00 00 
}
80102d92:	c9                   	leave  
80102d93:	c3                   	ret    

80102d94 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d94:	55                   	push   %ebp
80102d95:	89 e5                	mov    %esp,%ebp
80102d97:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d9d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102da2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102da7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102daa:	eb 12                	jmp    80102dbe <freerange+0x2a>
    kfree(p);
80102dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102daf:	89 04 24             	mov    %eax,(%esp)
80102db2:	e8 16 00 00 00       	call   80102dcd <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102db7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dc1:	05 00 10 00 00       	add    $0x1000,%eax
80102dc6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102dc9:	76 e1                	jbe    80102dac <freerange+0x18>
    kfree(p);
}
80102dcb:	c9                   	leave  
80102dcc:	c3                   	ret    

80102dcd <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dcd:	55                   	push   %ebp
80102dce:	89 e5                	mov    %esp,%ebp
80102dd0:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd6:	25 ff 0f 00 00       	and    $0xfff,%eax
80102ddb:	85 c0                	test   %eax,%eax
80102ddd:	75 18                	jne    80102df7 <kfree+0x2a>
80102ddf:	81 7d 08 d0 8c 11 80 	cmpl   $0x80118cd0,0x8(%ebp)
80102de6:	72 0f                	jb     80102df7 <kfree+0x2a>
80102de8:	8b 45 08             	mov    0x8(%ebp),%eax
80102deb:	05 00 00 00 80       	add    $0x80000000,%eax
80102df0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102df5:	76 0c                	jbe    80102e03 <kfree+0x36>
    panic("kfree");
80102df7:	c7 04 24 7b 9b 10 80 	movl   $0x80109b7b,(%esp)
80102dfe:	e8 51 d7 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e03:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102e0a:	00 
80102e0b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e12:	00 
80102e13:	8b 45 08             	mov    0x8(%ebp),%eax
80102e16:	89 04 24             	mov    %eax,(%esp)
80102e19:	e8 04 29 00 00       	call   80105722 <memset>

  if(kmem.use_lock){
80102e1e:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102e23:	85 c0                	test   %eax,%eax
80102e25:	74 48                	je     80102e6f <kfree+0xa2>
    acquire(&kmem.lock);
80102e27:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102e2e:	e8 8c 26 00 00       	call   801054bf <acquire>
    if(ticks > 1){
80102e33:	a1 c0 8b 11 80       	mov    0x80118bc0,%eax
80102e38:	83 f8 01             	cmp    $0x1,%eax
80102e3b:	76 32                	jbe    80102e6f <kfree+0xa2>
      int x = find(myproc()->cont->name);
80102e3d:	e8 9d 16 00 00       	call   801044df <myproc>
80102e42:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102e48:	83 c0 18             	add    $0x18,%eax
80102e4b:	89 04 24             	mov    %eax,(%esp)
80102e4e:	e8 18 63 00 00       	call   8010916b <find>
80102e53:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102e56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e5a:	78 13                	js     80102e6f <kfree+0xa2>
        reduce_curr_mem(1, x);
80102e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e63:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102e6a:	e8 4f 66 00 00       	call   801094be <reduce_curr_mem>
      }
    }
  }
  r = (struct run*)v;
80102e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102e75:	8b 15 98 5b 11 80    	mov    0x80115b98,%edx
80102e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e7e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e83:	a3 98 5b 11 80       	mov    %eax,0x80115b98
  if(kmem.use_lock)
80102e88:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102e8d:	85 c0                	test   %eax,%eax
80102e8f:	74 0c                	je     80102e9d <kfree+0xd0>
    release(&kmem.lock);
80102e91:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102e98:	e8 8c 26 00 00       	call   80105529 <release>
}
80102e9d:	c9                   	leave  
80102e9e:	c3                   	ret    

80102e9f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e9f:	55                   	push   %ebp
80102ea0:	89 e5                	mov    %esp,%ebp
80102ea2:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102ea5:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102eaa:	85 c0                	test   %eax,%eax
80102eac:	74 0c                	je     80102eba <kalloc+0x1b>
    acquire(&kmem.lock);
80102eae:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102eb5:	e8 05 26 00 00       	call   801054bf <acquire>
  }
  r = kmem.freelist;
80102eba:	a1 98 5b 11 80       	mov    0x80115b98,%eax
80102ebf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102ec2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ec6:	74 0a                	je     80102ed2 <kalloc+0x33>
    kmem.freelist = r->next;
80102ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ecb:	8b 00                	mov    (%eax),%eax
80102ecd:	a3 98 5b 11 80       	mov    %eax,0x80115b98
  if((char*)r != 0){
80102ed2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ed6:	74 72                	je     80102f4a <kalloc+0xab>
    if(ticks > 0){
80102ed8:	a1 c0 8b 11 80       	mov    0x80118bc0,%eax
80102edd:	85 c0                	test   %eax,%eax
80102edf:	74 69                	je     80102f4a <kalloc+0xab>
      int x = find(myproc()->cont->name);
80102ee1:	e8 f9 15 00 00       	call   801044df <myproc>
80102ee6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102eec:	83 c0 18             	add    $0x18,%eax
80102eef:	89 04 24             	mov    %eax,(%esp)
80102ef2:	e8 74 62 00 00       	call   8010916b <find>
80102ef7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102efa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102efe:	78 4a                	js     80102f4a <kalloc+0xab>
        int before = get_curr_mem(x);
80102f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f03:	89 04 24             	mov    %eax,(%esp)
80102f06:	e8 f8 63 00 00       	call   80109303 <get_curr_mem>
80102f0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        set_curr_mem(1, x);
80102f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f11:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102f1c:	e8 0a 65 00 00       	call   8010942b <set_curr_mem>
        int after = get_curr_mem(x);
80102f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f24:	89 04 24             	mov    %eax,(%esp)
80102f27:	e8 d7 63 00 00       	call   80109303 <get_curr_mem>
80102f2c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(before == after){
80102f2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f32:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80102f35:	75 13                	jne    80102f4a <kalloc+0xab>
          cstop_container_helper(myproc()->cont);
80102f37:	e8 a3 15 00 00       	call   801044df <myproc>
80102f3c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102f42:	89 04 24             	mov    %eax,(%esp)
80102f45:	e8 02 21 00 00       	call   8010504c <cstop_container_helper>
        }
      }
   }
  }
  if(kmem.use_lock)
80102f4a:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102f4f:	85 c0                	test   %eax,%eax
80102f51:	74 0c                	je     80102f5f <kalloc+0xc0>
    release(&kmem.lock);
80102f53:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102f5a:	e8 ca 25 00 00       	call   80105529 <release>
  return (char*)r;
80102f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102f62:	c9                   	leave  
80102f63:	c3                   	ret    

80102f64 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102f64:	55                   	push   %ebp
80102f65:	89 e5                	mov    %esp,%ebp
80102f67:	83 ec 14             	sub    $0x14,%esp
80102f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f6d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f74:	89 c2                	mov    %eax,%edx
80102f76:	ec                   	in     (%dx),%al
80102f77:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f7a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102f7d:	c9                   	leave  
80102f7e:	c3                   	ret    

80102f7f <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102f7f:	55                   	push   %ebp
80102f80:	89 e5                	mov    %esp,%ebp
80102f82:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102f85:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102f8c:	e8 d3 ff ff ff       	call   80102f64 <inb>
80102f91:	0f b6 c0             	movzbl %al,%eax
80102f94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f9a:	83 e0 01             	and    $0x1,%eax
80102f9d:	85 c0                	test   %eax,%eax
80102f9f:	75 0a                	jne    80102fab <kbdgetc+0x2c>
    return -1;
80102fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fa6:	e9 21 01 00 00       	jmp    801030cc <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102fab:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102fb2:	e8 ad ff ff ff       	call   80102f64 <inb>
80102fb7:	0f b6 c0             	movzbl %al,%eax
80102fba:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102fbd:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102fc4:	75 17                	jne    80102fdd <kbdgetc+0x5e>
    shift |= E0ESC;
80102fc6:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80102fcb:	83 c8 40             	or     $0x40,%eax
80102fce:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
    return 0;
80102fd3:	b8 00 00 00 00       	mov    $0x0,%eax
80102fd8:	e9 ef 00 00 00       	jmp    801030cc <kbdgetc+0x14d>
  } else if(data & 0x80){
80102fdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fe0:	25 80 00 00 00       	and    $0x80,%eax
80102fe5:	85 c0                	test   %eax,%eax
80102fe7:	74 44                	je     8010302d <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102fe9:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80102fee:	83 e0 40             	and    $0x40,%eax
80102ff1:	85 c0                	test   %eax,%eax
80102ff3:	75 08                	jne    80102ffd <kbdgetc+0x7e>
80102ff5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ff8:	83 e0 7f             	and    $0x7f,%eax
80102ffb:	eb 03                	jmp    80103000 <kbdgetc+0x81>
80102ffd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103000:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80103003:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103006:	05 20 b0 10 80       	add    $0x8010b020,%eax
8010300b:	8a 00                	mov    (%eax),%al
8010300d:	83 c8 40             	or     $0x40,%eax
80103010:	0f b6 c0             	movzbl %al,%eax
80103013:	f7 d0                	not    %eax
80103015:	89 c2                	mov    %eax,%edx
80103017:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
8010301c:	21 d0                	and    %edx,%eax
8010301e:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
    return 0;
80103023:	b8 00 00 00 00       	mov    $0x0,%eax
80103028:	e9 9f 00 00 00       	jmp    801030cc <kbdgetc+0x14d>
  } else if(shift & E0ESC){
8010302d:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103032:	83 e0 40             	and    $0x40,%eax
80103035:	85 c0                	test   %eax,%eax
80103037:	74 14                	je     8010304d <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103039:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103040:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103045:	83 e0 bf             	and    $0xffffffbf,%eax
80103048:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  }

  shift |= shiftcode[data];
8010304d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103050:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103055:	8a 00                	mov    (%eax),%al
80103057:	0f b6 d0             	movzbl %al,%edx
8010305a:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
8010305f:	09 d0                	or     %edx,%eax
80103061:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  shift ^= togglecode[data];
80103066:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103069:	05 20 b1 10 80       	add    $0x8010b120,%eax
8010306e:	8a 00                	mov    (%eax),%al
80103070:	0f b6 d0             	movzbl %al,%edx
80103073:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103078:	31 d0                	xor    %edx,%eax
8010307a:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  c = charcode[shift & (CTL | SHIFT)][data];
8010307f:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103084:	83 e0 03             	and    $0x3,%eax
80103087:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
8010308e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103091:	01 d0                	add    %edx,%eax
80103093:	8a 00                	mov    (%eax),%al
80103095:	0f b6 c0             	movzbl %al,%eax
80103098:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010309b:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030a0:	83 e0 08             	and    $0x8,%eax
801030a3:	85 c0                	test   %eax,%eax
801030a5:	74 22                	je     801030c9 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801030a7:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801030ab:	76 0c                	jbe    801030b9 <kbdgetc+0x13a>
801030ad:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801030b1:	77 06                	ja     801030b9 <kbdgetc+0x13a>
      c += 'A' - 'a';
801030b3:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801030b7:	eb 10                	jmp    801030c9 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801030b9:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801030bd:	76 0a                	jbe    801030c9 <kbdgetc+0x14a>
801030bf:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801030c3:	77 04                	ja     801030c9 <kbdgetc+0x14a>
      c += 'a' - 'A';
801030c5:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801030c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801030cc:	c9                   	leave  
801030cd:	c3                   	ret    

801030ce <kbdintr>:

void
kbdintr(void)
{
801030ce:	55                   	push   %ebp
801030cf:	89 e5                	mov    %esp,%ebp
801030d1:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
801030d4:	c7 04 24 7f 2f 10 80 	movl   $0x80102f7f,(%esp)
801030db:	e8 15 d7 ff ff       	call   801007f5 <consoleintr>
}
801030e0:	c9                   	leave  
801030e1:	c3                   	ret    
	...

801030e4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801030e4:	55                   	push   %ebp
801030e5:	89 e5                	mov    %esp,%ebp
801030e7:	83 ec 14             	sub    $0x14,%esp
801030ea:	8b 45 08             	mov    0x8(%ebp),%eax
801030ed:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801030f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030f4:	89 c2                	mov    %eax,%edx
801030f6:	ec                   	in     (%dx),%al
801030f7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801030fa:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801030fd:	c9                   	leave  
801030fe:	c3                   	ret    

801030ff <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801030ff:	55                   	push   %ebp
80103100:	89 e5                	mov    %esp,%ebp
80103102:	83 ec 08             	sub    $0x8,%esp
80103105:	8b 45 08             	mov    0x8(%ebp),%eax
80103108:	8b 55 0c             	mov    0xc(%ebp),%edx
8010310b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010310f:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103112:	8a 45 f8             	mov    -0x8(%ebp),%al
80103115:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103118:	ee                   	out    %al,(%dx)
}
80103119:	c9                   	leave  
8010311a:	c3                   	ret    

8010311b <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
8010311b:	55                   	push   %ebp
8010311c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010311e:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
80103123:	8b 55 08             	mov    0x8(%ebp),%edx
80103126:	c1 e2 02             	shl    $0x2,%edx
80103129:	01 c2                	add    %eax,%edx
8010312b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010312e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103130:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
80103135:	83 c0 20             	add    $0x20,%eax
80103138:	8b 00                	mov    (%eax),%eax
}
8010313a:	5d                   	pop    %ebp
8010313b:	c3                   	ret    

8010313c <lapicinit>:

void
lapicinit(void)
{
8010313c:	55                   	push   %ebp
8010313d:	89 e5                	mov    %esp,%ebp
8010313f:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80103142:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
80103147:	85 c0                	test   %eax,%eax
80103149:	75 05                	jne    80103150 <lapicinit+0x14>
    return;
8010314b:	e9 43 01 00 00       	jmp    80103293 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103150:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80103157:	00 
80103158:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
8010315f:	e8 b7 ff ff ff       	call   8010311b <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103164:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010316b:	00 
8010316c:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103173:	e8 a3 ff ff ff       	call   8010311b <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103178:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
8010317f:	00 
80103180:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103187:	e8 8f ff ff ff       	call   8010311b <lapicw>
  lapicw(TICR, 10000000);
8010318c:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103193:	00 
80103194:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010319b:	e8 7b ff ff ff       	call   8010311b <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801031a0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801031a7:	00 
801031a8:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801031af:	e8 67 ff ff ff       	call   8010311b <lapicw>
  lapicw(LINT1, MASKED);
801031b4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801031bb:	00 
801031bc:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801031c3:	e8 53 ff ff ff       	call   8010311b <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801031c8:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
801031cd:	83 c0 30             	add    $0x30,%eax
801031d0:	8b 00                	mov    (%eax),%eax
801031d2:	c1 e8 10             	shr    $0x10,%eax
801031d5:	0f b6 c0             	movzbl %al,%eax
801031d8:	83 f8 03             	cmp    $0x3,%eax
801031db:	76 14                	jbe    801031f1 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
801031dd:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801031e4:	00 
801031e5:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801031ec:	e8 2a ff ff ff       	call   8010311b <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801031f1:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801031f8:	00 
801031f9:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103200:	e8 16 ff ff ff       	call   8010311b <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103205:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010320c:	00 
8010320d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103214:	e8 02 ff ff ff       	call   8010311b <lapicw>
  lapicw(ESR, 0);
80103219:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103220:	00 
80103221:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103228:	e8 ee fe ff ff       	call   8010311b <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010322d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103234:	00 
80103235:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010323c:	e8 da fe ff ff       	call   8010311b <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103241:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103248:	00 
80103249:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103250:	e8 c6 fe ff ff       	call   8010311b <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103255:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
8010325c:	00 
8010325d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103264:	e8 b2 fe ff ff       	call   8010311b <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103269:	90                   	nop
8010326a:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
8010326f:	05 00 03 00 00       	add    $0x300,%eax
80103274:	8b 00                	mov    (%eax),%eax
80103276:	25 00 10 00 00       	and    $0x1000,%eax
8010327b:	85 c0                	test   %eax,%eax
8010327d:	75 eb                	jne    8010326a <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010327f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103286:	00 
80103287:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010328e:	e8 88 fe ff ff       	call   8010311b <lapicw>
}
80103293:	c9                   	leave  
80103294:	c3                   	ret    

80103295 <lapicid>:

int
lapicid(void)
{
80103295:	55                   	push   %ebp
80103296:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103298:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
8010329d:	85 c0                	test   %eax,%eax
8010329f:	75 07                	jne    801032a8 <lapicid+0x13>
    return 0;
801032a1:	b8 00 00 00 00       	mov    $0x0,%eax
801032a6:	eb 0d                	jmp    801032b5 <lapicid+0x20>
  return lapic[ID] >> 24;
801032a8:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
801032ad:	83 c0 20             	add    $0x20,%eax
801032b0:	8b 00                	mov    (%eax),%eax
801032b2:	c1 e8 18             	shr    $0x18,%eax
}
801032b5:	5d                   	pop    %ebp
801032b6:	c3                   	ret    

801032b7 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801032b7:	55                   	push   %ebp
801032b8:	89 e5                	mov    %esp,%ebp
801032ba:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801032bd:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
801032c2:	85 c0                	test   %eax,%eax
801032c4:	74 14                	je     801032da <lapiceoi+0x23>
    lapicw(EOI, 0);
801032c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801032cd:	00 
801032ce:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801032d5:	e8 41 fe ff ff       	call   8010311b <lapicw>
}
801032da:	c9                   	leave  
801032db:	c3                   	ret    

801032dc <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801032dc:	55                   	push   %ebp
801032dd:	89 e5                	mov    %esp,%ebp
}
801032df:	5d                   	pop    %ebp
801032e0:	c3                   	ret    

801032e1 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801032e1:	55                   	push   %ebp
801032e2:	89 e5                	mov    %esp,%ebp
801032e4:	83 ec 1c             	sub    $0x1c,%esp
801032e7:	8b 45 08             	mov    0x8(%ebp),%eax
801032ea:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801032ed:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801032f4:	00 
801032f5:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801032fc:	e8 fe fd ff ff       	call   801030ff <outb>
  outb(CMOS_PORT+1, 0x0A);
80103301:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103308:	00 
80103309:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103310:	e8 ea fd ff ff       	call   801030ff <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103315:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010331c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010331f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103324:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103327:	8d 50 02             	lea    0x2(%eax),%edx
8010332a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010332d:	c1 e8 04             	shr    $0x4,%eax
80103330:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103333:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103337:	c1 e0 18             	shl    $0x18,%eax
8010333a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010333e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103345:	e8 d1 fd ff ff       	call   8010311b <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010334a:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103351:	00 
80103352:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103359:	e8 bd fd ff ff       	call   8010311b <lapicw>
  microdelay(200);
8010335e:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103365:	e8 72 ff ff ff       	call   801032dc <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010336a:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103371:	00 
80103372:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103379:	e8 9d fd ff ff       	call   8010311b <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010337e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103385:	e8 52 ff ff ff       	call   801032dc <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010338a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103391:	eb 3f                	jmp    801033d2 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80103393:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103397:	c1 e0 18             	shl    $0x18,%eax
8010339a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010339e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801033a5:	e8 71 fd ff ff       	call   8010311b <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801033aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801033ad:	c1 e8 0c             	shr    $0xc,%eax
801033b0:	80 cc 06             	or     $0x6,%ah
801033b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801033b7:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801033be:	e8 58 fd ff ff       	call   8010311b <lapicw>
    microdelay(200);
801033c3:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801033ca:	e8 0d ff ff ff       	call   801032dc <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801033cf:	ff 45 fc             	incl   -0x4(%ebp)
801033d2:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801033d6:	7e bb                	jle    80103393 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801033d8:	c9                   	leave  
801033d9:	c3                   	ret    

801033da <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801033da:	55                   	push   %ebp
801033db:	89 e5                	mov    %esp,%ebp
801033dd:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801033e0:	8b 45 08             	mov    0x8(%ebp),%eax
801033e3:	0f b6 c0             	movzbl %al,%eax
801033e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801033ea:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801033f1:	e8 09 fd ff ff       	call   801030ff <outb>
  microdelay(200);
801033f6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801033fd:	e8 da fe ff ff       	call   801032dc <microdelay>

  return inb(CMOS_RETURN);
80103402:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103409:	e8 d6 fc ff ff       	call   801030e4 <inb>
8010340e:	0f b6 c0             	movzbl %al,%eax
}
80103411:	c9                   	leave  
80103412:	c3                   	ret    

80103413 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103413:	55                   	push   %ebp
80103414:	89 e5                	mov    %esp,%ebp
80103416:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103419:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103420:	e8 b5 ff ff ff       	call   801033da <cmos_read>
80103425:	8b 55 08             	mov    0x8(%ebp),%edx
80103428:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010342a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103431:	e8 a4 ff ff ff       	call   801033da <cmos_read>
80103436:	8b 55 08             	mov    0x8(%ebp),%edx
80103439:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010343c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103443:	e8 92 ff ff ff       	call   801033da <cmos_read>
80103448:	8b 55 08             	mov    0x8(%ebp),%edx
8010344b:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010344e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103455:	e8 80 ff ff ff       	call   801033da <cmos_read>
8010345a:	8b 55 08             	mov    0x8(%ebp),%edx
8010345d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103460:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103467:	e8 6e ff ff ff       	call   801033da <cmos_read>
8010346c:	8b 55 08             	mov    0x8(%ebp),%edx
8010346f:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103472:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103479:	e8 5c ff ff ff       	call   801033da <cmos_read>
8010347e:	8b 55 08             	mov    0x8(%ebp),%edx
80103481:	89 42 14             	mov    %eax,0x14(%edx)
}
80103484:	c9                   	leave  
80103485:	c3                   	ret    

80103486 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103486:	55                   	push   %ebp
80103487:	89 e5                	mov    %esp,%ebp
80103489:	57                   	push   %edi
8010348a:	56                   	push   %esi
8010348b:	53                   	push   %ebx
8010348c:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010348f:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103496:	e8 3f ff ff ff       	call   801033da <cmos_read>
8010349b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010349e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801034a1:	83 e0 04             	and    $0x4,%eax
801034a4:	85 c0                	test   %eax,%eax
801034a6:	0f 94 c0             	sete   %al
801034a9:	0f b6 c0             	movzbl %al,%eax
801034ac:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801034af:	8d 45 c8             	lea    -0x38(%ebp),%eax
801034b2:	89 04 24             	mov    %eax,(%esp)
801034b5:	e8 59 ff ff ff       	call   80103413 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801034ba:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801034c1:	e8 14 ff ff ff       	call   801033da <cmos_read>
801034c6:	25 80 00 00 00       	and    $0x80,%eax
801034cb:	85 c0                	test   %eax,%eax
801034cd:	74 02                	je     801034d1 <cmostime+0x4b>
        continue;
801034cf:	eb 36                	jmp    80103507 <cmostime+0x81>
    fill_rtcdate(&t2);
801034d1:	8d 45 b0             	lea    -0x50(%ebp),%eax
801034d4:	89 04 24             	mov    %eax,(%esp)
801034d7:	e8 37 ff ff ff       	call   80103413 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801034dc:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801034e3:	00 
801034e4:	8d 45 b0             	lea    -0x50(%ebp),%eax
801034e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801034eb:	8d 45 c8             	lea    -0x38(%ebp),%eax
801034ee:	89 04 24             	mov    %eax,(%esp)
801034f1:	e8 a3 22 00 00       	call   80105799 <memcmp>
801034f6:	85 c0                	test   %eax,%eax
801034f8:	75 0d                	jne    80103507 <cmostime+0x81>
      break;
801034fa:	90                   	nop
  }

  // convert
  if(bcd) {
801034fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801034ff:	0f 84 ac 00 00 00    	je     801035b1 <cmostime+0x12b>
80103505:	eb 02                	jmp    80103509 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103507:	eb a6                	jmp    801034af <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103509:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010350c:	c1 e8 04             	shr    $0x4,%eax
8010350f:	89 c2                	mov    %eax,%edx
80103511:	89 d0                	mov    %edx,%eax
80103513:	c1 e0 02             	shl    $0x2,%eax
80103516:	01 d0                	add    %edx,%eax
80103518:	01 c0                	add    %eax,%eax
8010351a:	8b 55 c8             	mov    -0x38(%ebp),%edx
8010351d:	83 e2 0f             	and    $0xf,%edx
80103520:	01 d0                	add    %edx,%eax
80103522:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103525:	8b 45 cc             	mov    -0x34(%ebp),%eax
80103528:	c1 e8 04             	shr    $0x4,%eax
8010352b:	89 c2                	mov    %eax,%edx
8010352d:	89 d0                	mov    %edx,%eax
8010352f:	c1 e0 02             	shl    $0x2,%eax
80103532:	01 d0                	add    %edx,%eax
80103534:	01 c0                	add    %eax,%eax
80103536:	8b 55 cc             	mov    -0x34(%ebp),%edx
80103539:	83 e2 0f             	and    $0xf,%edx
8010353c:	01 d0                	add    %edx,%eax
8010353e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103541:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103544:	c1 e8 04             	shr    $0x4,%eax
80103547:	89 c2                	mov    %eax,%edx
80103549:	89 d0                	mov    %edx,%eax
8010354b:	c1 e0 02             	shl    $0x2,%eax
8010354e:	01 d0                	add    %edx,%eax
80103550:	01 c0                	add    %eax,%eax
80103552:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103555:	83 e2 0f             	and    $0xf,%edx
80103558:	01 d0                	add    %edx,%eax
8010355a:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
8010355d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103560:	c1 e8 04             	shr    $0x4,%eax
80103563:	89 c2                	mov    %eax,%edx
80103565:	89 d0                	mov    %edx,%eax
80103567:	c1 e0 02             	shl    $0x2,%eax
8010356a:	01 d0                	add    %edx,%eax
8010356c:	01 c0                	add    %eax,%eax
8010356e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103571:	83 e2 0f             	and    $0xf,%edx
80103574:	01 d0                	add    %edx,%eax
80103576:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
80103579:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010357c:	c1 e8 04             	shr    $0x4,%eax
8010357f:	89 c2                	mov    %eax,%edx
80103581:	89 d0                	mov    %edx,%eax
80103583:	c1 e0 02             	shl    $0x2,%eax
80103586:	01 d0                	add    %edx,%eax
80103588:	01 c0                	add    %eax,%eax
8010358a:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010358d:	83 e2 0f             	and    $0xf,%edx
80103590:	01 d0                	add    %edx,%eax
80103592:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103595:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103598:	c1 e8 04             	shr    $0x4,%eax
8010359b:	89 c2                	mov    %eax,%edx
8010359d:	89 d0                	mov    %edx,%eax
8010359f:	c1 e0 02             	shl    $0x2,%eax
801035a2:	01 d0                	add    %edx,%eax
801035a4:	01 c0                	add    %eax,%eax
801035a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
801035a9:	83 e2 0f             	and    $0xf,%edx
801035ac:	01 d0                	add    %edx,%eax
801035ae:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
801035b1:	8b 45 08             	mov    0x8(%ebp),%eax
801035b4:	89 c2                	mov    %eax,%edx
801035b6:	8d 5d c8             	lea    -0x38(%ebp),%ebx
801035b9:	b8 06 00 00 00       	mov    $0x6,%eax
801035be:	89 d7                	mov    %edx,%edi
801035c0:	89 de                	mov    %ebx,%esi
801035c2:	89 c1                	mov    %eax,%ecx
801035c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801035c6:	8b 45 08             	mov    0x8(%ebp),%eax
801035c9:	8b 40 14             	mov    0x14(%eax),%eax
801035cc:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801035d2:	8b 45 08             	mov    0x8(%ebp),%eax
801035d5:	89 50 14             	mov    %edx,0x14(%eax)
}
801035d8:	83 c4 5c             	add    $0x5c,%esp
801035db:	5b                   	pop    %ebx
801035dc:	5e                   	pop    %esi
801035dd:	5f                   	pop    %edi
801035de:	5d                   	pop    %ebp
801035df:	c3                   	ret    

801035e0 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801035e0:	55                   	push   %ebp
801035e1:	89 e5                	mov    %esp,%ebp
801035e3:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801035e6:	c7 44 24 04 81 9b 10 	movl   $0x80109b81,0x4(%esp)
801035ed:	80 
801035ee:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
801035f5:	e8 a4 1e 00 00       	call   8010549e <initlock>
  readsb(dev, &sb);
801035fa:	8d 45 dc             	lea    -0x24(%ebp),%eax
801035fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80103601:	8b 45 08             	mov    0x8(%ebp),%eax
80103604:	89 04 24             	mov    %eax,(%esp)
80103607:	e8 b4 de ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
8010360c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010360f:	a3 d4 5b 11 80       	mov    %eax,0x80115bd4
  log.size = sb.nlog;
80103614:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103617:	a3 d8 5b 11 80       	mov    %eax,0x80115bd8
  log.dev = dev;
8010361c:	8b 45 08             	mov    0x8(%ebp),%eax
8010361f:	a3 e4 5b 11 80       	mov    %eax,0x80115be4
  recover_from_log();
80103624:	e8 95 01 00 00       	call   801037be <recover_from_log>
}
80103629:	c9                   	leave  
8010362a:	c3                   	ret    

8010362b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010362b:	55                   	push   %ebp
8010362c:	89 e5                	mov    %esp,%ebp
8010362e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103631:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103638:	e9 89 00 00 00       	jmp    801036c6 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010363d:	8b 15 d4 5b 11 80    	mov    0x80115bd4,%edx
80103643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103646:	01 d0                	add    %edx,%eax
80103648:	40                   	inc    %eax
80103649:	89 c2                	mov    %eax,%edx
8010364b:	a1 e4 5b 11 80       	mov    0x80115be4,%eax
80103650:	89 54 24 04          	mov    %edx,0x4(%esp)
80103654:	89 04 24             	mov    %eax,(%esp)
80103657:	e8 59 cb ff ff       	call   801001b5 <bread>
8010365c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010365f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103662:	83 c0 10             	add    $0x10,%eax
80103665:	8b 04 85 ac 5b 11 80 	mov    -0x7feea454(,%eax,4),%eax
8010366c:	89 c2                	mov    %eax,%edx
8010366e:	a1 e4 5b 11 80       	mov    0x80115be4,%eax
80103673:	89 54 24 04          	mov    %edx,0x4(%esp)
80103677:	89 04 24             	mov    %eax,(%esp)
8010367a:	e8 36 cb ff ff       	call   801001b5 <bread>
8010367f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103682:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103685:	8d 50 5c             	lea    0x5c(%eax),%edx
80103688:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010368b:	83 c0 5c             	add    $0x5c,%eax
8010368e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103695:	00 
80103696:	89 54 24 04          	mov    %edx,0x4(%esp)
8010369a:	89 04 24             	mov    %eax,(%esp)
8010369d:	e8 49 21 00 00       	call   801057eb <memmove>
    bwrite(dbuf);  // write dst to disk
801036a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036a5:	89 04 24             	mov    %eax,(%esp)
801036a8:	e8 3f cb ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
801036ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036b0:	89 04 24             	mov    %eax,(%esp)
801036b3:	e8 74 cb ff ff       	call   8010022c <brelse>
    brelse(dbuf);
801036b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036bb:	89 04 24             	mov    %eax,(%esp)
801036be:	e8 69 cb ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036c3:	ff 45 f4             	incl   -0xc(%ebp)
801036c6:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
801036cb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036ce:	0f 8f 69 ff ff ff    	jg     8010363d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801036d4:	c9                   	leave  
801036d5:	c3                   	ret    

801036d6 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801036d6:	55                   	push   %ebp
801036d7:	89 e5                	mov    %esp,%ebp
801036d9:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801036dc:	a1 d4 5b 11 80       	mov    0x80115bd4,%eax
801036e1:	89 c2                	mov    %eax,%edx
801036e3:	a1 e4 5b 11 80       	mov    0x80115be4,%eax
801036e8:	89 54 24 04          	mov    %edx,0x4(%esp)
801036ec:	89 04 24             	mov    %eax,(%esp)
801036ef:	e8 c1 ca ff ff       	call   801001b5 <bread>
801036f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801036f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036fa:	83 c0 5c             	add    $0x5c,%eax
801036fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103700:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103703:	8b 00                	mov    (%eax),%eax
80103705:	a3 e8 5b 11 80       	mov    %eax,0x80115be8
  for (i = 0; i < log.lh.n; i++) {
8010370a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103711:	eb 1a                	jmp    8010372d <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103713:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103716:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103719:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010371d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103720:	83 c2 10             	add    $0x10,%edx
80103723:	89 04 95 ac 5b 11 80 	mov    %eax,-0x7feea454(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010372a:	ff 45 f4             	incl   -0xc(%ebp)
8010372d:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
80103732:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103735:	7f dc                	jg     80103713 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010373a:	89 04 24             	mov    %eax,(%esp)
8010373d:	e8 ea ca ff ff       	call   8010022c <brelse>
}
80103742:	c9                   	leave  
80103743:	c3                   	ret    

80103744 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103744:	55                   	push   %ebp
80103745:	89 e5                	mov    %esp,%ebp
80103747:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010374a:	a1 d4 5b 11 80       	mov    0x80115bd4,%eax
8010374f:	89 c2                	mov    %eax,%edx
80103751:	a1 e4 5b 11 80       	mov    0x80115be4,%eax
80103756:	89 54 24 04          	mov    %edx,0x4(%esp)
8010375a:	89 04 24             	mov    %eax,(%esp)
8010375d:	e8 53 ca ff ff       	call   801001b5 <bread>
80103762:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103768:	83 c0 5c             	add    $0x5c,%eax
8010376b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010376e:	8b 15 e8 5b 11 80    	mov    0x80115be8,%edx
80103774:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103777:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103779:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103780:	eb 1a                	jmp    8010379c <write_head+0x58>
    hb->block[i] = log.lh.block[i];
80103782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103785:	83 c0 10             	add    $0x10,%eax
80103788:	8b 0c 85 ac 5b 11 80 	mov    -0x7feea454(,%eax,4),%ecx
8010378f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103792:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103795:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103799:	ff 45 f4             	incl   -0xc(%ebp)
8010379c:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
801037a1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037a4:	7f dc                	jg     80103782 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801037a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037a9:	89 04 24             	mov    %eax,(%esp)
801037ac:	e8 3b ca ff ff       	call   801001ec <bwrite>
  brelse(buf);
801037b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037b4:	89 04 24             	mov    %eax,(%esp)
801037b7:	e8 70 ca ff ff       	call   8010022c <brelse>
}
801037bc:	c9                   	leave  
801037bd:	c3                   	ret    

801037be <recover_from_log>:

static void
recover_from_log(void)
{
801037be:	55                   	push   %ebp
801037bf:	89 e5                	mov    %esp,%ebp
801037c1:	83 ec 08             	sub    $0x8,%esp
  read_head();
801037c4:	e8 0d ff ff ff       	call   801036d6 <read_head>
  install_trans(); // if committed, copy from log to disk
801037c9:	e8 5d fe ff ff       	call   8010362b <install_trans>
  log.lh.n = 0;
801037ce:	c7 05 e8 5b 11 80 00 	movl   $0x0,0x80115be8
801037d5:	00 00 00 
  write_head(); // clear the log
801037d8:	e8 67 ff ff ff       	call   80103744 <write_head>
}
801037dd:	c9                   	leave  
801037de:	c3                   	ret    

801037df <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801037df:	55                   	push   %ebp
801037e0:	89 e5                	mov    %esp,%ebp
801037e2:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801037e5:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
801037ec:	e8 ce 1c 00 00       	call   801054bf <acquire>
  while(1){
    if(log.committing){
801037f1:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
801037f6:	85 c0                	test   %eax,%eax
801037f8:	74 16                	je     80103810 <begin_op+0x31>
      sleep(&log, &log.lock);
801037fa:	c7 44 24 04 a0 5b 11 	movl   $0x80115ba0,0x4(%esp)
80103801:	80 
80103802:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80103809:	e8 82 15 00 00       	call   80104d90 <sleep>
8010380e:	eb 4d                	jmp    8010385d <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103810:	8b 15 e8 5b 11 80    	mov    0x80115be8,%edx
80103816:	a1 dc 5b 11 80       	mov    0x80115bdc,%eax
8010381b:	8d 48 01             	lea    0x1(%eax),%ecx
8010381e:	89 c8                	mov    %ecx,%eax
80103820:	c1 e0 02             	shl    $0x2,%eax
80103823:	01 c8                	add    %ecx,%eax
80103825:	01 c0                	add    %eax,%eax
80103827:	01 d0                	add    %edx,%eax
80103829:	83 f8 1e             	cmp    $0x1e,%eax
8010382c:	7e 16                	jle    80103844 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010382e:	c7 44 24 04 a0 5b 11 	movl   $0x80115ba0,0x4(%esp)
80103835:	80 
80103836:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
8010383d:	e8 4e 15 00 00       	call   80104d90 <sleep>
80103842:	eb 19                	jmp    8010385d <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103844:	a1 dc 5b 11 80       	mov    0x80115bdc,%eax
80103849:	40                   	inc    %eax
8010384a:	a3 dc 5b 11 80       	mov    %eax,0x80115bdc
      release(&log.lock);
8010384f:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80103856:	e8 ce 1c 00 00       	call   80105529 <release>
      break;
8010385b:	eb 02                	jmp    8010385f <begin_op+0x80>
    }
  }
8010385d:	eb 92                	jmp    801037f1 <begin_op+0x12>
}
8010385f:	c9                   	leave  
80103860:	c3                   	ret    

80103861 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103861:	55                   	push   %ebp
80103862:	89 e5                	mov    %esp,%ebp
80103864:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010386e:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80103875:	e8 45 1c 00 00       	call   801054bf <acquire>
  log.outstanding -= 1;
8010387a:	a1 dc 5b 11 80       	mov    0x80115bdc,%eax
8010387f:	48                   	dec    %eax
80103880:	a3 dc 5b 11 80       	mov    %eax,0x80115bdc
  if(log.committing)
80103885:	a1 e0 5b 11 80       	mov    0x80115be0,%eax
8010388a:	85 c0                	test   %eax,%eax
8010388c:	74 0c                	je     8010389a <end_op+0x39>
    panic("log.committing");
8010388e:	c7 04 24 85 9b 10 80 	movl   $0x80109b85,(%esp)
80103895:	e8 ba cc ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
8010389a:	a1 dc 5b 11 80       	mov    0x80115bdc,%eax
8010389f:	85 c0                	test   %eax,%eax
801038a1:	75 13                	jne    801038b6 <end_op+0x55>
    do_commit = 1;
801038a3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801038aa:	c7 05 e0 5b 11 80 01 	movl   $0x1,0x80115be0
801038b1:	00 00 00 
801038b4:	eb 0c                	jmp    801038c2 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801038b6:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
801038bd:	e8 a5 15 00 00       	call   80104e67 <wakeup>
  }
  release(&log.lock);
801038c2:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
801038c9:	e8 5b 1c 00 00       	call   80105529 <release>

  if(do_commit){
801038ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801038d2:	74 33                	je     80103907 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801038d4:	e8 db 00 00 00       	call   801039b4 <commit>
    acquire(&log.lock);
801038d9:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
801038e0:	e8 da 1b 00 00       	call   801054bf <acquire>
    log.committing = 0;
801038e5:	c7 05 e0 5b 11 80 00 	movl   $0x0,0x80115be0
801038ec:	00 00 00 
    wakeup(&log);
801038ef:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
801038f6:	e8 6c 15 00 00       	call   80104e67 <wakeup>
    release(&log.lock);
801038fb:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80103902:	e8 22 1c 00 00       	call   80105529 <release>
  }
}
80103907:	c9                   	leave  
80103908:	c3                   	ret    

80103909 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103909:	55                   	push   %ebp
8010390a:	89 e5                	mov    %esp,%ebp
8010390c:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010390f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103916:	e9 89 00 00 00       	jmp    801039a4 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010391b:	8b 15 d4 5b 11 80    	mov    0x80115bd4,%edx
80103921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103924:	01 d0                	add    %edx,%eax
80103926:	40                   	inc    %eax
80103927:	89 c2                	mov    %eax,%edx
80103929:	a1 e4 5b 11 80       	mov    0x80115be4,%eax
8010392e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103932:	89 04 24             	mov    %eax,(%esp)
80103935:	e8 7b c8 ff ff       	call   801001b5 <bread>
8010393a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010393d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103940:	83 c0 10             	add    $0x10,%eax
80103943:	8b 04 85 ac 5b 11 80 	mov    -0x7feea454(,%eax,4),%eax
8010394a:	89 c2                	mov    %eax,%edx
8010394c:	a1 e4 5b 11 80       	mov    0x80115be4,%eax
80103951:	89 54 24 04          	mov    %edx,0x4(%esp)
80103955:	89 04 24             	mov    %eax,(%esp)
80103958:	e8 58 c8 ff ff       	call   801001b5 <bread>
8010395d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103960:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103963:	8d 50 5c             	lea    0x5c(%eax),%edx
80103966:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103969:	83 c0 5c             	add    $0x5c,%eax
8010396c:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103973:	00 
80103974:	89 54 24 04          	mov    %edx,0x4(%esp)
80103978:	89 04 24             	mov    %eax,(%esp)
8010397b:	e8 6b 1e 00 00       	call   801057eb <memmove>
    bwrite(to);  // write the log
80103980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103983:	89 04 24             	mov    %eax,(%esp)
80103986:	e8 61 c8 ff ff       	call   801001ec <bwrite>
    brelse(from);
8010398b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010398e:	89 04 24             	mov    %eax,(%esp)
80103991:	e8 96 c8 ff ff       	call   8010022c <brelse>
    brelse(to);
80103996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103999:	89 04 24             	mov    %eax,(%esp)
8010399c:	e8 8b c8 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801039a1:	ff 45 f4             	incl   -0xc(%ebp)
801039a4:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
801039a9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039ac:	0f 8f 69 ff ff ff    	jg     8010391b <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
801039b2:	c9                   	leave  
801039b3:	c3                   	ret    

801039b4 <commit>:

static void
commit()
{
801039b4:	55                   	push   %ebp
801039b5:	89 e5                	mov    %esp,%ebp
801039b7:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801039ba:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
801039bf:	85 c0                	test   %eax,%eax
801039c1:	7e 1e                	jle    801039e1 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801039c3:	e8 41 ff ff ff       	call   80103909 <write_log>
    write_head();    // Write header to disk -- the real commit
801039c8:	e8 77 fd ff ff       	call   80103744 <write_head>
    install_trans(); // Now install writes to home locations
801039cd:	e8 59 fc ff ff       	call   8010362b <install_trans>
    log.lh.n = 0;
801039d2:	c7 05 e8 5b 11 80 00 	movl   $0x0,0x80115be8
801039d9:	00 00 00 
    write_head();    // Erase the transaction from the log
801039dc:	e8 63 fd ff ff       	call   80103744 <write_head>
  }
}
801039e1:	c9                   	leave  
801039e2:	c3                   	ret    

801039e3 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801039e3:	55                   	push   %ebp
801039e4:	89 e5                	mov    %esp,%ebp
801039e6:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801039e9:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
801039ee:	83 f8 1d             	cmp    $0x1d,%eax
801039f1:	7f 10                	jg     80103a03 <log_write+0x20>
801039f3:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
801039f8:	8b 15 d8 5b 11 80    	mov    0x80115bd8,%edx
801039fe:	4a                   	dec    %edx
801039ff:	39 d0                	cmp    %edx,%eax
80103a01:	7c 0c                	jl     80103a0f <log_write+0x2c>
    panic("too big a transaction");
80103a03:	c7 04 24 94 9b 10 80 	movl   $0x80109b94,(%esp)
80103a0a:	e8 45 cb ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103a0f:	a1 dc 5b 11 80       	mov    0x80115bdc,%eax
80103a14:	85 c0                	test   %eax,%eax
80103a16:	7f 0c                	jg     80103a24 <log_write+0x41>
    panic("log_write outside of trans");
80103a18:	c7 04 24 aa 9b 10 80 	movl   $0x80109baa,(%esp)
80103a1f:	e8 30 cb ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103a24:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80103a2b:	e8 8f 1a 00 00       	call   801054bf <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103a30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a37:	eb 1e                	jmp    80103a57 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a3c:	83 c0 10             	add    $0x10,%eax
80103a3f:	8b 04 85 ac 5b 11 80 	mov    -0x7feea454(,%eax,4),%eax
80103a46:	89 c2                	mov    %eax,%edx
80103a48:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4b:	8b 40 08             	mov    0x8(%eax),%eax
80103a4e:	39 c2                	cmp    %eax,%edx
80103a50:	75 02                	jne    80103a54 <log_write+0x71>
      break;
80103a52:	eb 0d                	jmp    80103a61 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103a54:	ff 45 f4             	incl   -0xc(%ebp)
80103a57:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
80103a5c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a5f:	7f d8                	jg     80103a39 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103a61:	8b 45 08             	mov    0x8(%ebp),%eax
80103a64:	8b 40 08             	mov    0x8(%eax),%eax
80103a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a6a:	83 c2 10             	add    $0x10,%edx
80103a6d:	89 04 95 ac 5b 11 80 	mov    %eax,-0x7feea454(,%edx,4)
  if (i == log.lh.n)
80103a74:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
80103a79:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a7c:	75 0b                	jne    80103a89 <log_write+0xa6>
    log.lh.n++;
80103a7e:	a1 e8 5b 11 80       	mov    0x80115be8,%eax
80103a83:	40                   	inc    %eax
80103a84:	a3 e8 5b 11 80       	mov    %eax,0x80115be8
  b->flags |= B_DIRTY; // prevent eviction
80103a89:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8c:	8b 00                	mov    (%eax),%eax
80103a8e:	83 c8 04             	or     $0x4,%eax
80103a91:	89 c2                	mov    %eax,%edx
80103a93:	8b 45 08             	mov    0x8(%ebp),%eax
80103a96:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a98:	c7 04 24 a0 5b 11 80 	movl   $0x80115ba0,(%esp)
80103a9f:	e8 85 1a 00 00       	call   80105529 <release>
}
80103aa4:	c9                   	leave  
80103aa5:	c3                   	ret    
	...

80103aa8 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103aa8:	55                   	push   %ebp
80103aa9:	89 e5                	mov    %esp,%ebp
80103aab:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103aae:	8b 55 08             	mov    0x8(%ebp),%edx
80103ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103ab7:	f0 87 02             	lock xchg %eax,(%edx)
80103aba:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103abd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103ac0:	c9                   	leave  
80103ac1:	c3                   	ret    

80103ac2 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103ac2:	55                   	push   %ebp
80103ac3:	89 e5                	mov    %esp,%ebp
80103ac5:	83 e4 f0             	and    $0xfffffff0,%esp
80103ac8:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103acb:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103ad2:	80 
80103ad3:	c7 04 24 d0 8c 11 80 	movl   $0x80118cd0,(%esp)
80103ada:	e8 59 f2 ff ff       	call   80102d38 <kinit1>
  kvmalloc();      // kernel page table
80103adf:	e8 f7 4c 00 00       	call   801087db <kvmalloc>
  mpinit();        // detect other processors
80103ae4:	e8 cc 03 00 00       	call   80103eb5 <mpinit>
  lapicinit();     // interrupt controller
80103ae9:	e8 4e f6 ff ff       	call   8010313c <lapicinit>
  seginit();       // segment descriptors
80103aee:	e8 d0 47 00 00       	call   801082c3 <seginit>
  picinit();       // disable pic
80103af3:	e8 0c 05 00 00       	call   80104004 <picinit>
  ioapicinit();    // another interrupt controller
80103af8:	e8 58 f1 ff ff       	call   80102c55 <ioapicinit>
  consoleinit();   // console hardware
80103afd:	e8 ed d0 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103b02:	e8 48 3b 00 00       	call   8010764f <uartinit>
  pinit();         // process table
80103b07:	e8 ee 08 00 00       	call   801043fa <pinit>
  tvinit();        // trap vectors
80103b0c:	e8 0b 37 00 00       	call   8010721c <tvinit>
  binit();         // buffer cache
80103b11:	e8 1e c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103b16:	e8 cb d5 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
80103b1b:	e8 41 ed ff ff       	call   80102861 <ideinit>
  startothers();   // start other processors
80103b20:	e8 88 00 00 00       	call   80103bad <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103b25:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103b2c:	8e 
80103b2d:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103b34:	e8 37 f2 ff ff       	call   80102d70 <kinit2>
  userinit();      // first user process
80103b39:	e8 e6 0a 00 00       	call   80104624 <userinit>
  container_init();
80103b3e:	e8 57 5b 00 00       	call   8010969a <container_init>
  mpmain();        // finish this processor's setup
80103b43:	e8 1a 00 00 00       	call   80103b62 <mpmain>

80103b48 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103b48:	55                   	push   %ebp
80103b49:	89 e5                	mov    %esp,%ebp
80103b4b:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103b4e:	e8 9f 4c 00 00       	call   801087f2 <switchkvm>
  seginit();
80103b53:	e8 6b 47 00 00       	call   801082c3 <seginit>
  lapicinit();
80103b58:	e8 df f5 ff ff       	call   8010313c <lapicinit>
  mpmain();
80103b5d:	e8 00 00 00 00       	call   80103b62 <mpmain>

80103b62 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103b62:	55                   	push   %ebp
80103b63:	89 e5                	mov    %esp,%ebp
80103b65:	53                   	push   %ebx
80103b66:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103b69:	e8 a8 08 00 00       	call   80104416 <cpuid>
80103b6e:	89 c3                	mov    %eax,%ebx
80103b70:	e8 a1 08 00 00       	call   80104416 <cpuid>
80103b75:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103b79:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b7d:	c7 04 24 c5 9b 10 80 	movl   $0x80109bc5,(%esp)
80103b84:	e8 38 c8 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103b89:	e8 eb 37 00 00       	call   80107379 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b8e:	e8 c8 08 00 00       	call   8010445b <mycpu>
80103b93:	05 a0 00 00 00       	add    $0xa0,%eax
80103b98:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103b9f:	00 
80103ba0:	89 04 24             	mov    %eax,(%esp)
80103ba3:	e8 00 ff ff ff       	call   80103aa8 <xchg>
  scheduler();     // start running processes
80103ba8:	e8 16 10 00 00       	call   80104bc3 <scheduler>

80103bad <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103bad:	55                   	push   %ebp
80103bae:	89 e5                	mov    %esp,%ebp
80103bb0:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103bb3:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103bba:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103bbf:	89 44 24 08          	mov    %eax,0x8(%esp)
80103bc3:	c7 44 24 04 8c d5 10 	movl   $0x8010d58c,0x4(%esp)
80103bca:	80 
80103bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bce:	89 04 24             	mov    %eax,(%esp)
80103bd1:	e8 15 1c 00 00       	call   801057eb <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103bd6:	c7 45 f4 a0 5c 11 80 	movl   $0x80115ca0,-0xc(%ebp)
80103bdd:	eb 75                	jmp    80103c54 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103bdf:	e8 77 08 00 00       	call   8010445b <mycpu>
80103be4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103be7:	75 02                	jne    80103beb <startothers+0x3e>
      continue;
80103be9:	eb 62                	jmp    80103c4d <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103beb:	e8 af f2 ff ff       	call   80102e9f <kalloc>
80103bf0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf6:	83 e8 04             	sub    $0x4,%eax
80103bf9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103bfc:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103c02:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c07:	83 e8 08             	sub    $0x8,%eax
80103c0a:	c7 00 48 3b 10 80    	movl   $0x80103b48,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c13:	8d 50 f4             	lea    -0xc(%eax),%edx
80103c16:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103c1b:	05 00 00 00 80       	add    $0x80000000,%eax
80103c20:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c25:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2e:	8a 00                	mov    (%eax),%al
80103c30:	0f b6 c0             	movzbl %al,%eax
80103c33:	89 54 24 04          	mov    %edx,0x4(%esp)
80103c37:	89 04 24             	mov    %eax,(%esp)
80103c3a:	e8 a2 f6 ff ff       	call   801032e1 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103c3f:	90                   	nop
80103c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c43:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103c49:	85 c0                	test   %eax,%eax
80103c4b:	74 f3                	je     80103c40 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103c4d:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103c54:	a1 20 62 11 80       	mov    0x80116220,%eax
80103c59:	89 c2                	mov    %eax,%edx
80103c5b:	89 d0                	mov    %edx,%eax
80103c5d:	c1 e0 02             	shl    $0x2,%eax
80103c60:	01 d0                	add    %edx,%eax
80103c62:	01 c0                	add    %eax,%eax
80103c64:	01 d0                	add    %edx,%eax
80103c66:	c1 e0 04             	shl    $0x4,%eax
80103c69:	05 a0 5c 11 80       	add    $0x80115ca0,%eax
80103c6e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c71:	0f 87 68 ff ff ff    	ja     80103bdf <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103c77:	c9                   	leave  
80103c78:	c3                   	ret    
80103c79:	00 00                	add    %al,(%eax)
	...

80103c7c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103c7c:	55                   	push   %ebp
80103c7d:	89 e5                	mov    %esp,%ebp
80103c7f:	83 ec 14             	sub    $0x14,%esp
80103c82:	8b 45 08             	mov    0x8(%ebp),%eax
80103c85:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c8c:	89 c2                	mov    %eax,%edx
80103c8e:	ec                   	in     (%dx),%al
80103c8f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c92:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103c95:	c9                   	leave  
80103c96:	c3                   	ret    

80103c97 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103c97:	55                   	push   %ebp
80103c98:	89 e5                	mov    %esp,%ebp
80103c9a:	83 ec 08             	sub    $0x8,%esp
80103c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca0:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ca3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ca7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103caa:	8a 45 f8             	mov    -0x8(%ebp),%al
80103cad:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103cb0:	ee                   	out    %al,(%dx)
}
80103cb1:	c9                   	leave  
80103cb2:	c3                   	ret    

80103cb3 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103cb3:	55                   	push   %ebp
80103cb4:	89 e5                	mov    %esp,%ebp
80103cb6:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103cb9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103cc0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103cc7:	eb 13                	jmp    80103cdc <sum+0x29>
    sum += addr[i];
80103cc9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80103ccf:	01 d0                	add    %edx,%eax
80103cd1:	8a 00                	mov    (%eax),%al
80103cd3:	0f b6 c0             	movzbl %al,%eax
80103cd6:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103cd9:	ff 45 fc             	incl   -0x4(%ebp)
80103cdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103cdf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103ce2:	7c e5                	jl     80103cc9 <sum+0x16>
    sum += addr[i];
  return sum;
80103ce4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103ce7:	c9                   	leave  
80103ce8:	c3                   	ret    

80103ce9 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103ce9:	55                   	push   %ebp
80103cea:	89 e5                	mov    %esp,%ebp
80103cec:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103cef:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf2:	05 00 00 00 80       	add    $0x80000000,%eax
80103cf7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103cfa:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d00:	01 d0                	add    %edx,%eax
80103d02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d08:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d0b:	eb 3f                	jmp    80103d4c <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103d0d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103d14:	00 
80103d15:	c7 44 24 04 dc 9b 10 	movl   $0x80109bdc,0x4(%esp)
80103d1c:	80 
80103d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d20:	89 04 24             	mov    %eax,(%esp)
80103d23:	e8 71 1a 00 00       	call   80105799 <memcmp>
80103d28:	85 c0                	test   %eax,%eax
80103d2a:	75 1c                	jne    80103d48 <mpsearch1+0x5f>
80103d2c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103d33:	00 
80103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d37:	89 04 24             	mov    %eax,(%esp)
80103d3a:	e8 74 ff ff ff       	call   80103cb3 <sum>
80103d3f:	84 c0                	test   %al,%al
80103d41:	75 05                	jne    80103d48 <mpsearch1+0x5f>
      return (struct mp*)p;
80103d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d46:	eb 11                	jmp    80103d59 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103d48:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d52:	72 b9                	jb     80103d0d <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d59:	c9                   	leave  
80103d5a:	c3                   	ret    

80103d5b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103d5b:	55                   	push   %ebp
80103d5c:	89 e5                	mov    %esp,%ebp
80103d5e:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103d61:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6b:	83 c0 0f             	add    $0xf,%eax
80103d6e:	8a 00                	mov    (%eax),%al
80103d70:	0f b6 c0             	movzbl %al,%eax
80103d73:	c1 e0 08             	shl    $0x8,%eax
80103d76:	89 c2                	mov    %eax,%edx
80103d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7b:	83 c0 0e             	add    $0xe,%eax
80103d7e:	8a 00                	mov    (%eax),%al
80103d80:	0f b6 c0             	movzbl %al,%eax
80103d83:	09 d0                	or     %edx,%eax
80103d85:	c1 e0 04             	shl    $0x4,%eax
80103d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d8f:	74 21                	je     80103db2 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103d91:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103d98:	00 
80103d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d9c:	89 04 24             	mov    %eax,(%esp)
80103d9f:	e8 45 ff ff ff       	call   80103ce9 <mpsearch1>
80103da4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103da7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103dab:	74 4e                	je     80103dfb <mpsearch+0xa0>
      return mp;
80103dad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103db0:	eb 5d                	jmp    80103e0f <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db5:	83 c0 14             	add    $0x14,%eax
80103db8:	8a 00                	mov    (%eax),%al
80103dba:	0f b6 c0             	movzbl %al,%eax
80103dbd:	c1 e0 08             	shl    $0x8,%eax
80103dc0:	89 c2                	mov    %eax,%edx
80103dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc5:	83 c0 13             	add    $0x13,%eax
80103dc8:	8a 00                	mov    (%eax),%al
80103dca:	0f b6 c0             	movzbl %al,%eax
80103dcd:	09 d0                	or     %edx,%eax
80103dcf:	c1 e0 0a             	shl    $0xa,%eax
80103dd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd8:	2d 00 04 00 00       	sub    $0x400,%eax
80103ddd:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103de4:	00 
80103de5:	89 04 24             	mov    %eax,(%esp)
80103de8:	e8 fc fe ff ff       	call   80103ce9 <mpsearch1>
80103ded:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103df0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103df4:	74 05                	je     80103dfb <mpsearch+0xa0>
      return mp;
80103df6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103df9:	eb 14                	jmp    80103e0f <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103dfb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103e02:	00 
80103e03:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103e0a:	e8 da fe ff ff       	call   80103ce9 <mpsearch1>
}
80103e0f:	c9                   	leave  
80103e10:	c3                   	ret    

80103e11 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103e11:	55                   	push   %ebp
80103e12:	89 e5                	mov    %esp,%ebp
80103e14:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103e17:	e8 3f ff ff ff       	call   80103d5b <mpsearch>
80103e1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e23:	74 0a                	je     80103e2f <mpconfig+0x1e>
80103e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e28:	8b 40 04             	mov    0x4(%eax),%eax
80103e2b:	85 c0                	test   %eax,%eax
80103e2d:	75 07                	jne    80103e36 <mpconfig+0x25>
    return 0;
80103e2f:	b8 00 00 00 00       	mov    $0x0,%eax
80103e34:	eb 7d                	jmp    80103eb3 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e39:	8b 40 04             	mov    0x4(%eax),%eax
80103e3c:	05 00 00 00 80       	add    $0x80000000,%eax
80103e41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103e44:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103e4b:	00 
80103e4c:	c7 44 24 04 e1 9b 10 	movl   $0x80109be1,0x4(%esp)
80103e53:	80 
80103e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e57:	89 04 24             	mov    %eax,(%esp)
80103e5a:	e8 3a 19 00 00       	call   80105799 <memcmp>
80103e5f:	85 c0                	test   %eax,%eax
80103e61:	74 07                	je     80103e6a <mpconfig+0x59>
    return 0;
80103e63:	b8 00 00 00 00       	mov    $0x0,%eax
80103e68:	eb 49                	jmp    80103eb3 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e6d:	8a 40 06             	mov    0x6(%eax),%al
80103e70:	3c 01                	cmp    $0x1,%al
80103e72:	74 11                	je     80103e85 <mpconfig+0x74>
80103e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e77:	8a 40 06             	mov    0x6(%eax),%al
80103e7a:	3c 04                	cmp    $0x4,%al
80103e7c:	74 07                	je     80103e85 <mpconfig+0x74>
    return 0;
80103e7e:	b8 00 00 00 00       	mov    $0x0,%eax
80103e83:	eb 2e                	jmp    80103eb3 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e88:	8b 40 04             	mov    0x4(%eax),%eax
80103e8b:	0f b7 c0             	movzwl %ax,%eax
80103e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e95:	89 04 24             	mov    %eax,(%esp)
80103e98:	e8 16 fe ff ff       	call   80103cb3 <sum>
80103e9d:	84 c0                	test   %al,%al
80103e9f:	74 07                	je     80103ea8 <mpconfig+0x97>
    return 0;
80103ea1:	b8 00 00 00 00       	mov    $0x0,%eax
80103ea6:	eb 0b                	jmp    80103eb3 <mpconfig+0xa2>
  *pmp = mp;
80103ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80103eab:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103eae:	89 10                	mov    %edx,(%eax)
  return conf;
80103eb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103eb3:	c9                   	leave  
80103eb4:	c3                   	ret    

80103eb5 <mpinit>:

void
mpinit(void)
{
80103eb5:	55                   	push   %ebp
80103eb6:	89 e5                	mov    %esp,%ebp
80103eb8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103ebb:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103ebe:	89 04 24             	mov    %eax,(%esp)
80103ec1:	e8 4b ff ff ff       	call   80103e11 <mpconfig>
80103ec6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ec9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ecd:	75 0c                	jne    80103edb <mpinit+0x26>
    panic("Expect to run on an SMP");
80103ecf:	c7 04 24 e6 9b 10 80 	movl   $0x80109be6,(%esp)
80103ed6:	e8 79 c6 ff ff       	call   80100554 <panic>
  ismp = 1;
80103edb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee5:	8b 40 24             	mov    0x24(%eax),%eax
80103ee8:	a3 9c 5b 11 80       	mov    %eax,0x80115b9c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103eed:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef0:	83 c0 2c             	add    $0x2c,%eax
80103ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef9:	8b 40 04             	mov    0x4(%eax),%eax
80103efc:	0f b7 d0             	movzwl %ax,%edx
80103eff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f02:	01 d0                	add    %edx,%eax
80103f04:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103f07:	eb 7d                	jmp    80103f86 <mpinit+0xd1>
    switch(*p){
80103f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f0c:	8a 00                	mov    (%eax),%al
80103f0e:	0f b6 c0             	movzbl %al,%eax
80103f11:	83 f8 04             	cmp    $0x4,%eax
80103f14:	77 68                	ja     80103f7e <mpinit+0xc9>
80103f16:	8b 04 85 20 9c 10 80 	mov    -0x7fef63e0(,%eax,4),%eax
80103f1d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103f25:	a1 20 62 11 80       	mov    0x80116220,%eax
80103f2a:	83 f8 07             	cmp    $0x7,%eax
80103f2d:	7f 2c                	jg     80103f5b <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103f2f:	8b 15 20 62 11 80    	mov    0x80116220,%edx
80103f35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f38:	8a 48 01             	mov    0x1(%eax),%cl
80103f3b:	89 d0                	mov    %edx,%eax
80103f3d:	c1 e0 02             	shl    $0x2,%eax
80103f40:	01 d0                	add    %edx,%eax
80103f42:	01 c0                	add    %eax,%eax
80103f44:	01 d0                	add    %edx,%eax
80103f46:	c1 e0 04             	shl    $0x4,%eax
80103f49:	05 a0 5c 11 80       	add    $0x80115ca0,%eax
80103f4e:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103f50:	a1 20 62 11 80       	mov    0x80116220,%eax
80103f55:	40                   	inc    %eax
80103f56:	a3 20 62 11 80       	mov    %eax,0x80116220
      }
      p += sizeof(struct mpproc);
80103f5b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f5f:	eb 25                	jmp    80103f86 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f64:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103f67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f6a:	8a 40 01             	mov    0x1(%eax),%al
80103f6d:	a2 80 5c 11 80       	mov    %al,0x80115c80
      p += sizeof(struct mpioapic);
80103f72:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f76:	eb 0e                	jmp    80103f86 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f78:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f7c:	eb 08                	jmp    80103f86 <mpinit+0xd1>
    default:
      ismp = 0;
80103f7e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103f85:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f89:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103f8c:	0f 82 77 ff ff ff    	jb     80103f09 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103f92:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f96:	75 0c                	jne    80103fa4 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103f98:	c7 04 24 00 9c 10 80 	movl   $0x80109c00,(%esp)
80103f9f:	e8 b0 c5 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103fa4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fa7:	8a 40 0c             	mov    0xc(%eax),%al
80103faa:	84 c0                	test   %al,%al
80103fac:	74 36                	je     80103fe4 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103fae:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103fb5:	00 
80103fb6:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103fbd:	e8 d5 fc ff ff       	call   80103c97 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103fc2:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103fc9:	e8 ae fc ff ff       	call   80103c7c <inb>
80103fce:	83 c8 01             	or     $0x1,%eax
80103fd1:	0f b6 c0             	movzbl %al,%eax
80103fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fd8:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103fdf:	e8 b3 fc ff ff       	call   80103c97 <outb>
  }
}
80103fe4:	c9                   	leave  
80103fe5:	c3                   	ret    
	...

80103fe8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103fe8:	55                   	push   %ebp
80103fe9:	89 e5                	mov    %esp,%ebp
80103feb:	83 ec 08             	sub    $0x8,%esp
80103fee:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff1:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ff4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ff8:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ffb:	8a 45 f8             	mov    -0x8(%ebp),%al
80103ffe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104001:	ee                   	out    %al,(%dx)
}
80104002:	c9                   	leave  
80104003:	c3                   	ret    

80104004 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80104004:	55                   	push   %ebp
80104005:	89 e5                	mov    %esp,%ebp
80104007:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010400a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104011:	00 
80104012:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104019:	e8 ca ff ff ff       	call   80103fe8 <outb>
  outb(IO_PIC2+1, 0xFF);
8010401e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104025:	00 
80104026:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
8010402d:	e8 b6 ff ff ff       	call   80103fe8 <outb>
}
80104032:	c9                   	leave  
80104033:	c3                   	ret    

80104034 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104034:	55                   	push   %ebp
80104035:	89 e5                	mov    %esp,%ebp
80104037:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
8010403a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104041:	8b 45 0c             	mov    0xc(%ebp),%eax
80104044:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010404a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010404d:	8b 10                	mov    (%eax),%edx
8010404f:	8b 45 08             	mov    0x8(%ebp),%eax
80104052:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104054:	e8 a9 d0 ff ff       	call   80101102 <filealloc>
80104059:	8b 55 08             	mov    0x8(%ebp),%edx
8010405c:	89 02                	mov    %eax,(%edx)
8010405e:	8b 45 08             	mov    0x8(%ebp),%eax
80104061:	8b 00                	mov    (%eax),%eax
80104063:	85 c0                	test   %eax,%eax
80104065:	0f 84 c8 00 00 00    	je     80104133 <pipealloc+0xff>
8010406b:	e8 92 d0 ff ff       	call   80101102 <filealloc>
80104070:	8b 55 0c             	mov    0xc(%ebp),%edx
80104073:	89 02                	mov    %eax,(%edx)
80104075:	8b 45 0c             	mov    0xc(%ebp),%eax
80104078:	8b 00                	mov    (%eax),%eax
8010407a:	85 c0                	test   %eax,%eax
8010407c:	0f 84 b1 00 00 00    	je     80104133 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104082:	e8 18 ee ff ff       	call   80102e9f <kalloc>
80104087:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010408a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010408e:	75 05                	jne    80104095 <pipealloc+0x61>
    goto bad;
80104090:	e9 9e 00 00 00       	jmp    80104133 <pipealloc+0xff>
  p->readopen = 1;
80104095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104098:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010409f:	00 00 00 
  p->writeopen = 1;
801040a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040ac:	00 00 00 
  p->nwrite = 0;
801040af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040b9:	00 00 00 
  p->nread = 0;
801040bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bf:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040c6:	00 00 00 
  initlock(&p->lock, "pipe");
801040c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cc:	c7 44 24 04 34 9c 10 	movl   $0x80109c34,0x4(%esp)
801040d3:	80 
801040d4:	89 04 24             	mov    %eax,(%esp)
801040d7:	e8 c2 13 00 00       	call   8010549e <initlock>
  (*f0)->type = FD_PIPE;
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	8b 00                	mov    (%eax),%eax
801040e1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040e7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ea:	8b 00                	mov    (%eax),%eax
801040ec:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040f0:	8b 45 08             	mov    0x8(%ebp),%eax
801040f3:	8b 00                	mov    (%eax),%eax
801040f5:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040f9:	8b 45 08             	mov    0x8(%ebp),%eax
801040fc:	8b 00                	mov    (%eax),%eax
801040fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104101:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104104:	8b 45 0c             	mov    0xc(%ebp),%eax
80104107:	8b 00                	mov    (%eax),%eax
80104109:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010410f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104112:	8b 00                	mov    (%eax),%eax
80104114:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104118:	8b 45 0c             	mov    0xc(%ebp),%eax
8010411b:	8b 00                	mov    (%eax),%eax
8010411d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104121:	8b 45 0c             	mov    0xc(%ebp),%eax
80104124:	8b 00                	mov    (%eax),%eax
80104126:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104129:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010412c:	b8 00 00 00 00       	mov    $0x0,%eax
80104131:	eb 42                	jmp    80104175 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104133:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104137:	74 0b                	je     80104144 <pipealloc+0x110>
    kfree((char*)p);
80104139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413c:	89 04 24             	mov    %eax,(%esp)
8010413f:	e8 89 ec ff ff       	call   80102dcd <kfree>
  if(*f0)
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	8b 00                	mov    (%eax),%eax
80104149:	85 c0                	test   %eax,%eax
8010414b:	74 0d                	je     8010415a <pipealloc+0x126>
    fileclose(*f0);
8010414d:	8b 45 08             	mov    0x8(%ebp),%eax
80104150:	8b 00                	mov    (%eax),%eax
80104152:	89 04 24             	mov    %eax,(%esp)
80104155:	e8 50 d0 ff ff       	call   801011aa <fileclose>
  if(*f1)
8010415a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415d:	8b 00                	mov    (%eax),%eax
8010415f:	85 c0                	test   %eax,%eax
80104161:	74 0d                	je     80104170 <pipealloc+0x13c>
    fileclose(*f1);
80104163:	8b 45 0c             	mov    0xc(%ebp),%eax
80104166:	8b 00                	mov    (%eax),%eax
80104168:	89 04 24             	mov    %eax,(%esp)
8010416b:	e8 3a d0 ff ff       	call   801011aa <fileclose>
  return -1;
80104170:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104175:	c9                   	leave  
80104176:	c3                   	ret    

80104177 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104177:	55                   	push   %ebp
80104178:	89 e5                	mov    %esp,%ebp
8010417a:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
8010417d:	8b 45 08             	mov    0x8(%ebp),%eax
80104180:	89 04 24             	mov    %eax,(%esp)
80104183:	e8 37 13 00 00       	call   801054bf <acquire>
  if(writable){
80104188:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010418c:	74 1f                	je     801041ad <pipeclose+0x36>
    p->writeopen = 0;
8010418e:	8b 45 08             	mov    0x8(%ebp),%eax
80104191:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104198:	00 00 00 
    wakeup(&p->nread);
8010419b:	8b 45 08             	mov    0x8(%ebp),%eax
8010419e:	05 34 02 00 00       	add    $0x234,%eax
801041a3:	89 04 24             	mov    %eax,(%esp)
801041a6:	e8 bc 0c 00 00       	call   80104e67 <wakeup>
801041ab:	eb 1d                	jmp    801041ca <pipeclose+0x53>
  } else {
    p->readopen = 0;
801041ad:	8b 45 08             	mov    0x8(%ebp),%eax
801041b0:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041b7:	00 00 00 
    wakeup(&p->nwrite);
801041ba:	8b 45 08             	mov    0x8(%ebp),%eax
801041bd:	05 38 02 00 00       	add    $0x238,%eax
801041c2:	89 04 24             	mov    %eax,(%esp)
801041c5:	e8 9d 0c 00 00       	call   80104e67 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041ca:	8b 45 08             	mov    0x8(%ebp),%eax
801041cd:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041d3:	85 c0                	test   %eax,%eax
801041d5:	75 25                	jne    801041fc <pipeclose+0x85>
801041d7:	8b 45 08             	mov    0x8(%ebp),%eax
801041da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041e0:	85 c0                	test   %eax,%eax
801041e2:	75 18                	jne    801041fc <pipeclose+0x85>
    release(&p->lock);
801041e4:	8b 45 08             	mov    0x8(%ebp),%eax
801041e7:	89 04 24             	mov    %eax,(%esp)
801041ea:	e8 3a 13 00 00       	call   80105529 <release>
    kfree((char*)p);
801041ef:	8b 45 08             	mov    0x8(%ebp),%eax
801041f2:	89 04 24             	mov    %eax,(%esp)
801041f5:	e8 d3 eb ff ff       	call   80102dcd <kfree>
801041fa:	eb 0b                	jmp    80104207 <pipeclose+0x90>
  } else
    release(&p->lock);
801041fc:	8b 45 08             	mov    0x8(%ebp),%eax
801041ff:	89 04 24             	mov    %eax,(%esp)
80104202:	e8 22 13 00 00       	call   80105529 <release>
}
80104207:	c9                   	leave  
80104208:	c3                   	ret    

80104209 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104209:	55                   	push   %ebp
8010420a:	89 e5                	mov    %esp,%ebp
8010420c:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
8010420f:	8b 45 08             	mov    0x8(%ebp),%eax
80104212:	89 04 24             	mov    %eax,(%esp)
80104215:	e8 a5 12 00 00       	call   801054bf <acquire>
  for(i = 0; i < n; i++){
8010421a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104221:	e9 a3 00 00 00       	jmp    801042c9 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104226:	eb 56                	jmp    8010427e <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80104228:	8b 45 08             	mov    0x8(%ebp),%eax
8010422b:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104231:	85 c0                	test   %eax,%eax
80104233:	74 0c                	je     80104241 <pipewrite+0x38>
80104235:	e8 a5 02 00 00       	call   801044df <myproc>
8010423a:	8b 40 24             	mov    0x24(%eax),%eax
8010423d:	85 c0                	test   %eax,%eax
8010423f:	74 15                	je     80104256 <pipewrite+0x4d>
        release(&p->lock);
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	89 04 24             	mov    %eax,(%esp)
80104247:	e8 dd 12 00 00       	call   80105529 <release>
        return -1;
8010424c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104251:	e9 9d 00 00 00       	jmp    801042f3 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104256:	8b 45 08             	mov    0x8(%ebp),%eax
80104259:	05 34 02 00 00       	add    $0x234,%eax
8010425e:	89 04 24             	mov    %eax,(%esp)
80104261:	e8 01 0c 00 00       	call   80104e67 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104266:	8b 45 08             	mov    0x8(%ebp),%eax
80104269:	8b 55 08             	mov    0x8(%ebp),%edx
8010426c:	81 c2 38 02 00 00    	add    $0x238,%edx
80104272:	89 44 24 04          	mov    %eax,0x4(%esp)
80104276:	89 14 24             	mov    %edx,(%esp)
80104279:	e8 12 0b 00 00       	call   80104d90 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010427e:	8b 45 08             	mov    0x8(%ebp),%eax
80104281:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104287:	8b 45 08             	mov    0x8(%ebp),%eax
8010428a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104290:	05 00 02 00 00       	add    $0x200,%eax
80104295:	39 c2                	cmp    %eax,%edx
80104297:	74 8f                	je     80104228 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104299:	8b 45 08             	mov    0x8(%ebp),%eax
8010429c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042a2:	8d 48 01             	lea    0x1(%eax),%ecx
801042a5:	8b 55 08             	mov    0x8(%ebp),%edx
801042a8:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042ae:	25 ff 01 00 00       	and    $0x1ff,%eax
801042b3:	89 c1                	mov    %eax,%ecx
801042b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801042bb:	01 d0                	add    %edx,%eax
801042bd:	8a 10                	mov    (%eax),%dl
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801042c6:	ff 45 f4             	incl   -0xc(%ebp)
801042c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cc:	3b 45 10             	cmp    0x10(%ebp),%eax
801042cf:	0f 8c 51 ff ff ff    	jl     80104226 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801042d5:	8b 45 08             	mov    0x8(%ebp),%eax
801042d8:	05 34 02 00 00       	add    $0x234,%eax
801042dd:	89 04 24             	mov    %eax,(%esp)
801042e0:	e8 82 0b 00 00       	call   80104e67 <wakeup>
  release(&p->lock);
801042e5:	8b 45 08             	mov    0x8(%ebp),%eax
801042e8:	89 04 24             	mov    %eax,(%esp)
801042eb:	e8 39 12 00 00       	call   80105529 <release>
  return n;
801042f0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042f3:	c9                   	leave  
801042f4:	c3                   	ret    

801042f5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042f5:	55                   	push   %ebp
801042f6:	89 e5                	mov    %esp,%ebp
801042f8:	53                   	push   %ebx
801042f9:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801042fc:	8b 45 08             	mov    0x8(%ebp),%eax
801042ff:	89 04 24             	mov    %eax,(%esp)
80104302:	e8 b8 11 00 00       	call   801054bf <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104307:	eb 39                	jmp    80104342 <piperead+0x4d>
    if(myproc()->killed){
80104309:	e8 d1 01 00 00       	call   801044df <myproc>
8010430e:	8b 40 24             	mov    0x24(%eax),%eax
80104311:	85 c0                	test   %eax,%eax
80104313:	74 15                	je     8010432a <piperead+0x35>
      release(&p->lock);
80104315:	8b 45 08             	mov    0x8(%ebp),%eax
80104318:	89 04 24             	mov    %eax,(%esp)
8010431b:	e8 09 12 00 00       	call   80105529 <release>
      return -1;
80104320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104325:	e9 b3 00 00 00       	jmp    801043dd <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010432a:	8b 45 08             	mov    0x8(%ebp),%eax
8010432d:	8b 55 08             	mov    0x8(%ebp),%edx
80104330:	81 c2 34 02 00 00    	add    $0x234,%edx
80104336:	89 44 24 04          	mov    %eax,0x4(%esp)
8010433a:	89 14 24             	mov    %edx,(%esp)
8010433d:	e8 4e 0a 00 00       	call   80104d90 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104342:	8b 45 08             	mov    0x8(%ebp),%eax
80104345:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010434b:	8b 45 08             	mov    0x8(%ebp),%eax
8010434e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104354:	39 c2                	cmp    %eax,%edx
80104356:	75 0d                	jne    80104365 <piperead+0x70>
80104358:	8b 45 08             	mov    0x8(%ebp),%eax
8010435b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104361:	85 c0                	test   %eax,%eax
80104363:	75 a4                	jne    80104309 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104365:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010436c:	eb 49                	jmp    801043b7 <piperead+0xc2>
    if(p->nread == p->nwrite)
8010436e:	8b 45 08             	mov    0x8(%ebp),%eax
80104371:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104377:	8b 45 08             	mov    0x8(%ebp),%eax
8010437a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104380:	39 c2                	cmp    %eax,%edx
80104382:	75 02                	jne    80104386 <piperead+0x91>
      break;
80104384:	eb 39                	jmp    801043bf <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104386:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104389:	8b 45 0c             	mov    0xc(%ebp),%eax
8010438c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010438f:	8b 45 08             	mov    0x8(%ebp),%eax
80104392:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104398:	8d 48 01             	lea    0x1(%eax),%ecx
8010439b:	8b 55 08             	mov    0x8(%ebp),%edx
8010439e:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043a4:	25 ff 01 00 00       	and    $0x1ff,%eax
801043a9:	89 c2                	mov    %eax,%edx
801043ab:	8b 45 08             	mov    0x8(%ebp),%eax
801043ae:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
801043b2:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b4:	ff 45 f4             	incl   -0xc(%ebp)
801043b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ba:	3b 45 10             	cmp    0x10(%ebp),%eax
801043bd:	7c af                	jl     8010436e <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801043bf:	8b 45 08             	mov    0x8(%ebp),%eax
801043c2:	05 38 02 00 00       	add    $0x238,%eax
801043c7:	89 04 24             	mov    %eax,(%esp)
801043ca:	e8 98 0a 00 00       	call   80104e67 <wakeup>
  release(&p->lock);
801043cf:	8b 45 08             	mov    0x8(%ebp),%eax
801043d2:	89 04 24             	mov    %eax,(%esp)
801043d5:	e8 4f 11 00 00       	call   80105529 <release>
  return i;
801043da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043dd:	83 c4 24             	add    $0x24,%esp
801043e0:	5b                   	pop    %ebx
801043e1:	5d                   	pop    %ebp
801043e2:	c3                   	ret    
	...

801043e4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801043e4:	55                   	push   %ebp
801043e5:	89 e5                	mov    %esp,%ebp
801043e7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043ea:	9c                   	pushf  
801043eb:	58                   	pop    %eax
801043ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043f2:	c9                   	leave  
801043f3:	c3                   	ret    

801043f4 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801043f4:	55                   	push   %ebp
801043f5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043f7:	fb                   	sti    
}
801043f8:	5d                   	pop    %ebp
801043f9:	c3                   	ret    

801043fa <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043fa:	55                   	push   %ebp
801043fb:	89 e5                	mov    %esp,%ebp
801043fd:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104400:	c7 44 24 04 3c 9c 10 	movl   $0x80109c3c,0x4(%esp)
80104407:	80 
80104408:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
8010440f:	e8 8a 10 00 00       	call   8010549e <initlock>
}
80104414:	c9                   	leave  
80104415:	c3                   	ret    

80104416 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104416:	55                   	push   %ebp
80104417:	89 e5                	mov    %esp,%ebp
80104419:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010441c:	e8 3a 00 00 00       	call   8010445b <mycpu>
80104421:	89 c2                	mov    %eax,%edx
80104423:	b8 a0 5c 11 80       	mov    $0x80115ca0,%eax
80104428:	29 c2                	sub    %eax,%edx
8010442a:	89 d0                	mov    %edx,%eax
8010442c:	c1 f8 04             	sar    $0x4,%eax
8010442f:	89 c1                	mov    %eax,%ecx
80104431:	89 ca                	mov    %ecx,%edx
80104433:	c1 e2 03             	shl    $0x3,%edx
80104436:	01 ca                	add    %ecx,%edx
80104438:	89 d0                	mov    %edx,%eax
8010443a:	c1 e0 05             	shl    $0x5,%eax
8010443d:	29 d0                	sub    %edx,%eax
8010443f:	c1 e0 02             	shl    $0x2,%eax
80104442:	01 c8                	add    %ecx,%eax
80104444:	c1 e0 03             	shl    $0x3,%eax
80104447:	01 c8                	add    %ecx,%eax
80104449:	89 c2                	mov    %eax,%edx
8010444b:	c1 e2 0f             	shl    $0xf,%edx
8010444e:	29 c2                	sub    %eax,%edx
80104450:	c1 e2 02             	shl    $0x2,%edx
80104453:	01 ca                	add    %ecx,%edx
80104455:	89 d0                	mov    %edx,%eax
80104457:	f7 d8                	neg    %eax
}
80104459:	c9                   	leave  
8010445a:	c3                   	ret    

8010445b <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010445b:	55                   	push   %ebp
8010445c:	89 e5                	mov    %esp,%ebp
8010445e:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104461:	e8 7e ff ff ff       	call   801043e4 <readeflags>
80104466:	25 00 02 00 00       	and    $0x200,%eax
8010446b:	85 c0                	test   %eax,%eax
8010446d:	74 0c                	je     8010447b <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
8010446f:	c7 04 24 44 9c 10 80 	movl   $0x80109c44,(%esp)
80104476:	e8 d9 c0 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
8010447b:	e8 15 ee ff ff       	call   80103295 <lapicid>
80104480:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104483:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010448a:	eb 3b                	jmp    801044c7 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
8010448c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010448f:	89 d0                	mov    %edx,%eax
80104491:	c1 e0 02             	shl    $0x2,%eax
80104494:	01 d0                	add    %edx,%eax
80104496:	01 c0                	add    %eax,%eax
80104498:	01 d0                	add    %edx,%eax
8010449a:	c1 e0 04             	shl    $0x4,%eax
8010449d:	05 a0 5c 11 80       	add    $0x80115ca0,%eax
801044a2:	8a 00                	mov    (%eax),%al
801044a4:	0f b6 c0             	movzbl %al,%eax
801044a7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801044aa:	75 18                	jne    801044c4 <mycpu+0x69>
      return &cpus[i];
801044ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044af:	89 d0                	mov    %edx,%eax
801044b1:	c1 e0 02             	shl    $0x2,%eax
801044b4:	01 d0                	add    %edx,%eax
801044b6:	01 c0                	add    %eax,%eax
801044b8:	01 d0                	add    %edx,%eax
801044ba:	c1 e0 04             	shl    $0x4,%eax
801044bd:	05 a0 5c 11 80       	add    $0x80115ca0,%eax
801044c2:	eb 19                	jmp    801044dd <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044c4:	ff 45 f4             	incl   -0xc(%ebp)
801044c7:	a1 20 62 11 80       	mov    0x80116220,%eax
801044cc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801044cf:	7c bb                	jl     8010448c <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
801044d1:	c7 04 24 6a 9c 10 80 	movl   $0x80109c6a,(%esp)
801044d8:	e8 77 c0 ff ff       	call   80100554 <panic>
}
801044dd:	c9                   	leave  
801044de:	c3                   	ret    

801044df <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801044df:	55                   	push   %ebp
801044e0:	89 e5                	mov    %esp,%ebp
801044e2:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801044e5:	e8 34 11 00 00       	call   8010561e <pushcli>
  c = mycpu();
801044ea:	e8 6c ff ff ff       	call   8010445b <mycpu>
801044ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801044f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801044fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801044fe:	e8 65 11 00 00       	call   80105668 <popcli>
  return p;
80104503:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104506:	c9                   	leave  
80104507:	c3                   	ret    

80104508 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104508:	55                   	push   %ebp
80104509:	89 e5                	mov    %esp,%ebp
8010450b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010450e:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104515:	e8 a5 0f 00 00       	call   801054bf <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010451a:	c7 45 f4 74 62 11 80 	movl   $0x80116274,-0xc(%ebp)
80104521:	eb 53                	jmp    80104576 <allocproc+0x6e>
    if(p->state == UNUSED)
80104523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104526:	8b 40 0c             	mov    0xc(%eax),%eax
80104529:	85 c0                	test   %eax,%eax
8010452b:	75 42                	jne    8010456f <allocproc+0x67>
      goto found;
8010452d:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010452e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104531:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104538:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010453d:	8d 50 01             	lea    0x1(%eax),%edx
80104540:	89 15 00 d0 10 80    	mov    %edx,0x8010d000
80104546:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104549:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010454c:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104553:	e8 d1 0f 00 00       	call   80105529 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104558:	e8 42 e9 ff ff       	call   80102e9f <kalloc>
8010455d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104560:	89 42 08             	mov    %eax,0x8(%edx)
80104563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104566:	8b 40 08             	mov    0x8(%eax),%eax
80104569:	85 c0                	test   %eax,%eax
8010456b:	75 39                	jne    801045a6 <allocproc+0x9e>
8010456d:	eb 26                	jmp    80104595 <allocproc+0x8d>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010456f:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104576:	81 7d f4 74 83 11 80 	cmpl   $0x80118374,-0xc(%ebp)
8010457d:	72 a4                	jb     80104523 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
8010457f:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104586:	e8 9e 0f 00 00       	call   80105529 <release>
  return 0;
8010458b:	b8 00 00 00 00       	mov    $0x0,%eax
80104590:	e9 8d 00 00 00       	jmp    80104622 <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104598:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010459f:	b8 00 00 00 00       	mov    $0x0,%eax
801045a4:	eb 7c                	jmp    80104622 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
801045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a9:	8b 40 08             	mov    0x8(%eax),%eax
801045ac:	05 00 10 00 00       	add    $0x1000,%eax
801045b1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801045b4:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801045b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045be:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801045c1:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801045c5:	ba d8 71 10 80       	mov    $0x801071d8,%edx
801045ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045cd:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801045cf:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801045d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045d9:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045df:	8b 40 1c             	mov    0x1c(%eax),%eax
801045e2:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801045e9:	00 
801045ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801045f1:	00 
801045f2:	89 04 24             	mov    %eax,(%esp)
801045f5:	e8 28 11 00 00       	call   80105722 <memset>
  p->context->eip = (uint)forkret;
801045fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fd:	8b 40 1c             	mov    0x1c(%eax),%eax
80104600:	ba 51 4d 10 80       	mov    $0x80104d51,%edx
80104605:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
80104608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460b:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
80104612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104615:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010461c:	00 00 00 
  // }
  //SUCC
  // if(p->cont == NULL)
  //   cprintf("p container is now null.\n");

  return p;
8010461f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104622:	c9                   	leave  
80104623:	c3                   	ret    

80104624 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104624:	55                   	push   %ebp
80104625:	89 e5                	mov    %esp,%ebp
80104627:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010462a:	e8 d9 fe ff ff       	call   80104508 <allocproc>
8010462f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104635:	a3 20 d9 10 80       	mov    %eax,0x8010d920
  if((p->pgdir = setupkvm()) == 0)
8010463a:	e8 f3 40 00 00       	call   80108732 <setupkvm>
8010463f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104642:	89 42 04             	mov    %eax,0x4(%edx)
80104645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104648:	8b 40 04             	mov    0x4(%eax),%eax
8010464b:	85 c0                	test   %eax,%eax
8010464d:	75 0c                	jne    8010465b <userinit+0x37>
    panic("userinit: out of memory?");
8010464f:	c7 04 24 7a 9c 10 80 	movl   $0x80109c7a,(%esp)
80104656:	e8 f9 be ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010465b:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104663:	8b 40 04             	mov    0x4(%eax),%eax
80104666:	89 54 24 08          	mov    %edx,0x8(%esp)
8010466a:	c7 44 24 04 60 d5 10 	movl   $0x8010d560,0x4(%esp)
80104671:	80 
80104672:	89 04 24             	mov    %eax,(%esp)
80104675:	e8 19 43 00 00       	call   80108993 <inituvm>
  p->sz = PGSIZE;
8010467a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104686:	8b 40 18             	mov    0x18(%eax),%eax
80104689:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104690:	00 
80104691:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104698:	00 
80104699:	89 04 24             	mov    %eax,(%esp)
8010469c:	e8 81 10 00 00       	call   80105722 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a4:	8b 40 18             	mov    0x18(%eax),%eax
801046a7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b0:	8b 40 18             	mov    0x18(%eax),%eax
801046b3:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bc:	8b 50 18             	mov    0x18(%eax),%edx
801046bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c2:	8b 40 18             	mov    0x18(%eax),%eax
801046c5:	8b 40 2c             	mov    0x2c(%eax),%eax
801046c8:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
801046cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cf:	8b 50 18             	mov    0x18(%eax),%edx
801046d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d5:	8b 40 18             	mov    0x18(%eax),%eax
801046d8:	8b 40 2c             	mov    0x2c(%eax),%eax
801046db:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
801046df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e2:	8b 40 18             	mov    0x18(%eax),%eax
801046e5:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ef:	8b 40 18             	mov    0x18(%eax),%eax
801046f2:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fc:	8b 40 18             	mov    0x18(%eax),%eax
801046ff:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104709:	83 c0 6c             	add    $0x6c,%eax
8010470c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104713:	00 
80104714:	c7 44 24 04 93 9c 10 	movl   $0x80109c93,0x4(%esp)
8010471b:	80 
8010471c:	89 04 24             	mov    %eax,(%esp)
8010471f:	e8 0a 12 00 00       	call   8010592e <safestrcpy>
  p->cwd = namei("/");
80104724:	c7 04 24 9c 9c 10 80 	movl   $0x80109c9c,(%esp)
8010472b:	e8 28 e0 ff ff       	call   80102758 <namei>
80104730:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104733:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104736:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
8010473d:	e8 7d 0d 00 00       	call   801054bf <acquire>

  p->state = RUNNABLE;
80104742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104745:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010474c:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104753:	e8 d1 0d 00 00       	call   80105529 <release>
}
80104758:	c9                   	leave  
80104759:	c3                   	ret    

8010475a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010475a:	55                   	push   %ebp
8010475b:	89 e5                	mov    %esp,%ebp
8010475d:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
80104760:	e8 7a fd ff ff       	call   801044df <myproc>
80104765:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010476b:	8b 00                	mov    (%eax),%eax
8010476d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104770:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104774:	7e 31                	jle    801047a7 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104776:	8b 55 08             	mov    0x8(%ebp),%edx
80104779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477c:	01 c2                	add    %eax,%edx
8010477e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104781:	8b 40 04             	mov    0x4(%eax),%eax
80104784:	89 54 24 08          	mov    %edx,0x8(%esp)
80104788:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010478b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010478f:	89 04 24             	mov    %eax,(%esp)
80104792:	e8 67 43 00 00       	call   80108afe <allocuvm>
80104797:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010479a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010479e:	75 3e                	jne    801047de <growproc+0x84>
      return -1;
801047a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a5:	eb 4f                	jmp    801047f6 <growproc+0x9c>
  } else if(n < 0){
801047a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047ab:	79 31                	jns    801047de <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047ad:	8b 55 08             	mov    0x8(%ebp),%edx
801047b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b3:	01 c2                	add    %eax,%edx
801047b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047b8:	8b 40 04             	mov    0x4(%eax),%eax
801047bb:	89 54 24 08          	mov    %edx,0x8(%esp)
801047bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801047c6:	89 04 24             	mov    %eax,(%esp)
801047c9:	e8 46 44 00 00       	call   80108c14 <deallocuvm>
801047ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047d5:	75 07                	jne    801047de <growproc+0x84>
      return -1;
801047d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047dc:	eb 18                	jmp    801047f6 <growproc+0x9c>
  }
  curproc->sz = sz;
801047de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047e4:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801047e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e9:	89 04 24             	mov    %eax,(%esp)
801047ec:	e8 1b 40 00 00       	call   8010880c <switchuvm>
  return 0;
801047f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047f6:	c9                   	leave  
801047f7:	c3                   	ret    

801047f8 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801047f8:	55                   	push   %ebp
801047f9:	89 e5                	mov    %esp,%ebp
801047fb:	57                   	push   %edi
801047fc:	56                   	push   %esi
801047fd:	53                   	push   %ebx
801047fe:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104801:	e8 d9 fc ff ff       	call   801044df <myproc>
80104806:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104809:	e8 fa fc ff ff       	call   80104508 <allocproc>
8010480e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104811:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104815:	75 0a                	jne    80104821 <fork+0x29>
    return -1;
80104817:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010481c:	e9 47 01 00 00       	jmp    80104968 <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104821:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104824:	8b 10                	mov    (%eax),%edx
80104826:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104829:	8b 40 04             	mov    0x4(%eax),%eax
8010482c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104830:	89 04 24             	mov    %eax,(%esp)
80104833:	e8 7c 45 00 00       	call   80108db4 <copyuvm>
80104838:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010483b:	89 42 04             	mov    %eax,0x4(%edx)
8010483e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104841:	8b 40 04             	mov    0x4(%eax),%eax
80104844:	85 c0                	test   %eax,%eax
80104846:	75 2c                	jne    80104874 <fork+0x7c>
    kfree(np->kstack);
80104848:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010484b:	8b 40 08             	mov    0x8(%eax),%eax
8010484e:	89 04 24             	mov    %eax,(%esp)
80104851:	e8 77 e5 ff ff       	call   80102dcd <kfree>
    np->kstack = 0;
80104856:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104859:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104860:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104863:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010486a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010486f:	e9 f4 00 00 00       	jmp    80104968 <fork+0x170>
  }
  np->sz = curproc->sz;
80104874:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104877:	8b 10                	mov    (%eax),%edx
80104879:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010487c:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010487e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104881:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104884:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104887:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010488a:	8b 50 18             	mov    0x18(%eax),%edx
8010488d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104890:	8b 40 18             	mov    0x18(%eax),%eax
80104893:	89 c3                	mov    %eax,%ebx
80104895:	b8 13 00 00 00       	mov    $0x13,%eax
8010489a:	89 d7                	mov    %edx,%edi
8010489c:	89 de                	mov    %ebx,%esi
8010489e:	89 c1                	mov    %eax,%ecx
801048a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801048a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048a5:	8b 40 18             	mov    0x18(%eax),%eax
801048a8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801048af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048b6:	eb 36                	jmp    801048ee <fork+0xf6>
    if(curproc->ofile[i])
801048b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048be:	83 c2 08             	add    $0x8,%edx
801048c1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048c5:	85 c0                	test   %eax,%eax
801048c7:	74 22                	je     801048eb <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
801048c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048cf:	83 c2 08             	add    $0x8,%edx
801048d2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048d6:	89 04 24             	mov    %eax,(%esp)
801048d9:	e8 84 c8 ff ff       	call   80101162 <filedup>
801048de:	8b 55 dc             	mov    -0x24(%ebp),%edx
801048e1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801048e4:	83 c1 08             	add    $0x8,%ecx
801048e7:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801048eb:	ff 45 e4             	incl   -0x1c(%ebp)
801048ee:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801048f2:	7e c4                	jle    801048b8 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801048f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048f7:	8b 40 68             	mov    0x68(%eax),%eax
801048fa:	89 04 24             	mov    %eax,(%esp)
801048fd:	e8 8e d1 ff ff       	call   80101a90 <idup>
80104902:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104905:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104908:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010490b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010490e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104911:	83 c0 6c             	add    $0x6c,%eax
80104914:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010491b:	00 
8010491c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104920:	89 04 24             	mov    %eax,(%esp)
80104923:	e8 06 10 00 00       	call   8010592e <safestrcpy>



  pid = np->pid;
80104928:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010492b:	8b 40 10             	mov    0x10(%eax),%eax
8010492e:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104931:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104938:	e8 82 0b 00 00       	call   801054bf <acquire>

  np->state = RUNNABLE;
8010493d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104940:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
80104947:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494a:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104950:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104953:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
80104959:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104960:	e8 c4 0b 00 00       	call   80105529 <release>

  return pid;
80104965:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104968:	83 c4 2c             	add    $0x2c,%esp
8010496b:	5b                   	pop    %ebx
8010496c:	5e                   	pop    %esi
8010496d:	5f                   	pop    %edi
8010496e:	5d                   	pop    %ebp
8010496f:	c3                   	ret    

80104970 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104970:	55                   	push   %ebp
80104971:	89 e5                	mov    %esp,%ebp
80104973:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
80104976:	e8 64 fb ff ff       	call   801044df <myproc>
8010497b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010497e:	a1 20 d9 10 80       	mov    0x8010d920,%eax
80104983:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104986:	75 0c                	jne    80104994 <exit+0x24>
    panic("init exiting");
80104988:	c7 04 24 9e 9c 10 80 	movl   $0x80109c9e,(%esp)
8010498f:	e8 c0 bb ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104994:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010499b:	eb 3a                	jmp    801049d7 <exit+0x67>
    if(curproc->ofile[fd]){
8010499d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049a3:	83 c2 08             	add    $0x8,%edx
801049a6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049aa:	85 c0                	test   %eax,%eax
801049ac:	74 26                	je     801049d4 <exit+0x64>
      fileclose(curproc->ofile[fd]);
801049ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049b4:	83 c2 08             	add    $0x8,%edx
801049b7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049bb:	89 04 24             	mov    %eax,(%esp)
801049be:	e8 e7 c7 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
801049c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049c9:	83 c2 08             	add    $0x8,%edx
801049cc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801049d3:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049d4:	ff 45 f0             	incl   -0x10(%ebp)
801049d7:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801049db:	7e c0                	jle    8010499d <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
801049dd:	e8 fd ed ff ff       	call   801037df <begin_op>
  iput(curproc->cwd);
801049e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049e5:	8b 40 68             	mov    0x68(%eax),%eax
801049e8:	89 04 24             	mov    %eax,(%esp)
801049eb:	e8 20 d2 ff ff       	call   80101c10 <iput>
  end_op();
801049f0:	e8 6c ee ff ff       	call   80103861 <end_op>
  curproc->cwd = 0;
801049f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f8:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049ff:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104a06:	e8 b4 0a 00 00       	call   801054bf <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a0e:	8b 40 14             	mov    0x14(%eax),%eax
80104a11:	89 04 24             	mov    %eax,(%esp)
80104a14:	e8 0d 04 00 00       	call   80104e26 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a19:	c7 45 f4 74 62 11 80 	movl   $0x80116274,-0xc(%ebp)
80104a20:	eb 36                	jmp    80104a58 <exit+0xe8>
    if(p->parent == curproc){
80104a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a25:	8b 40 14             	mov    0x14(%eax),%eax
80104a28:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104a2b:	75 24                	jne    80104a51 <exit+0xe1>
      p->parent = initproc;
80104a2d:	8b 15 20 d9 10 80    	mov    0x8010d920,%edx
80104a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a36:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a3f:	83 f8 05             	cmp    $0x5,%eax
80104a42:	75 0d                	jne    80104a51 <exit+0xe1>
        wakeup1(initproc);
80104a44:	a1 20 d9 10 80       	mov    0x8010d920,%eax
80104a49:	89 04 24             	mov    %eax,(%esp)
80104a4c:	e8 d5 03 00 00       	call   80104e26 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a51:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a58:	81 7d f4 74 83 11 80 	cmpl   $0x80118374,-0xc(%ebp)
80104a5f:	72 c1                	jb     80104a22 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104a61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a64:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a6b:	e8 01 02 00 00       	call   80104c71 <sched>
  panic("zombie exit");
80104a70:	c7 04 24 ab 9c 10 80 	movl   $0x80109cab,(%esp)
80104a77:	e8 d8 ba ff ff       	call   80100554 <panic>

80104a7c <strcmp1>:
}


int
strcmp1(const char *p, const char *q)
{
80104a7c:	55                   	push   %ebp
80104a7d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104a7f:	eb 06                	jmp    80104a87 <strcmp1+0xb>
    p++, q++;
80104a81:	ff 45 08             	incl   0x8(%ebp)
80104a84:	ff 45 0c             	incl   0xc(%ebp)


int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104a87:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8a:	8a 00                	mov    (%eax),%al
80104a8c:	84 c0                	test   %al,%al
80104a8e:	74 0e                	je     80104a9e <strcmp1+0x22>
80104a90:	8b 45 08             	mov    0x8(%ebp),%eax
80104a93:	8a 10                	mov    (%eax),%dl
80104a95:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a98:	8a 00                	mov    (%eax),%al
80104a9a:	38 c2                	cmp    %al,%dl
80104a9c:	74 e3                	je     80104a81 <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa1:	8a 00                	mov    (%eax),%al
80104aa3:	0f b6 d0             	movzbl %al,%edx
80104aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aa9:	8a 00                	mov    (%eax),%al
80104aab:	0f b6 c0             	movzbl %al,%eax
80104aae:	29 c2                	sub    %eax,%edx
80104ab0:	89 d0                	mov    %edx,%eax
}
80104ab2:	5d                   	pop    %ebp
80104ab3:	c3                   	ret    

80104ab4 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104ab4:	55                   	push   %ebp
80104ab5:	89 e5                	mov    %esp,%ebp
80104ab7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104aba:	e8 20 fa ff ff       	call   801044df <myproc>
80104abf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104ac2:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104ac9:	e8 f1 09 00 00       	call   801054bf <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104ace:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad5:	c7 45 f4 74 62 11 80 	movl   $0x80116274,-0xc(%ebp)
80104adc:	e9 98 00 00 00       	jmp    80104b79 <wait+0xc5>
      if(p->parent != curproc)
80104ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae4:	8b 40 14             	mov    0x14(%eax),%eax
80104ae7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104aea:	74 05                	je     80104af1 <wait+0x3d>
        continue;
80104aec:	e9 81 00 00 00       	jmp    80104b72 <wait+0xbe>
      havekids = 1;
80104af1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afb:	8b 40 0c             	mov    0xc(%eax),%eax
80104afe:	83 f8 05             	cmp    $0x5,%eax
80104b01:	75 6f                	jne    80104b72 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b06:	8b 40 10             	mov    0x10(%eax),%eax
80104b09:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0f:	8b 40 08             	mov    0x8(%eax),%eax
80104b12:	89 04 24             	mov    %eax,(%esp)
80104b15:	e8 b3 e2 ff ff       	call   80102dcd <kfree>
        p->kstack = 0;
80104b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b27:	8b 40 04             	mov    0x4(%eax),%eax
80104b2a:	89 04 24             	mov    %eax,(%esp)
80104b2d:	e8 a6 41 00 00       	call   80108cd8 <freevm>
        p->pid = 0;
80104b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b35:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b49:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b50:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104b61:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104b68:	e8 bc 09 00 00       	call   80105529 <release>
        return pid;
80104b6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b70:	eb 4f                	jmp    80104bc1 <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b72:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104b79:	81 7d f4 74 83 11 80 	cmpl   $0x80118374,-0xc(%ebp)
80104b80:	0f 82 5b ff ff ff    	jb     80104ae1 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104b86:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b8a:	74 0a                	je     80104b96 <wait+0xe2>
80104b8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b8f:	8b 40 24             	mov    0x24(%eax),%eax
80104b92:	85 c0                	test   %eax,%eax
80104b94:	74 13                	je     80104ba9 <wait+0xf5>
      release(&ptable.lock);
80104b96:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104b9d:	e8 87 09 00 00       	call   80105529 <release>
      return -1;
80104ba2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba7:	eb 18                	jmp    80104bc1 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104ba9:	c7 44 24 04 40 62 11 	movl   $0x80116240,0x4(%esp)
80104bb0:	80 
80104bb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104bb4:	89 04 24             	mov    %eax,(%esp)
80104bb7:	e8 d4 01 00 00       	call   80104d90 <sleep>
  }
80104bbc:	e9 0d ff ff ff       	jmp    80104ace <wait+0x1a>
}
80104bc1:	c9                   	leave  
80104bc2:	c3                   	ret    

80104bc3 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104bc3:	55                   	push   %ebp
80104bc4:	89 e5                	mov    %esp,%ebp
80104bc6:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104bc9:	e8 8d f8 ff ff       	call   8010445b <mycpu>
80104bce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bd4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104bdb:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104bde:	e8 11 f8 ff ff       	call   801043f4 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104be3:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104bea:	e8 d0 08 00 00       	call   801054bf <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bef:	c7 45 f4 74 62 11 80 	movl   $0x80116274,-0xc(%ebp)
80104bf6:	eb 5f                	jmp    80104c57 <scheduler+0x94>
      if(p->state != RUNNABLE)
80104bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfb:	8b 40 0c             	mov    0xc(%eax),%eax
80104bfe:	83 f8 03             	cmp    $0x3,%eax
80104c01:	74 02                	je     80104c05 <scheduler+0x42>
        continue;
80104c03:	eb 4b                	jmp    80104c50 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c0b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c14:	89 04 24             	mov    %eax,(%esp)
80104c17:	e8 f0 3b 00 00       	call   8010880c <switchuvm>
      p->state = RUNNING;
80104c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1f:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c29:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c2f:	83 c2 04             	add    $0x4,%edx
80104c32:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c36:	89 14 24             	mov    %edx,(%esp)
80104c39:	e8 5e 0d 00 00       	call   8010599c <swtch>
      switchkvm();
80104c3e:	e8 af 3b 00 00       	call   801087f2 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c46:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c4d:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c50:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104c57:	81 7d f4 74 83 11 80 	cmpl   $0x80118374,-0xc(%ebp)
80104c5e:	72 98                	jb     80104bf8 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104c60:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104c67:	e8 bd 08 00 00       	call   80105529 <release>

  }
80104c6c:	e9 6d ff ff ff       	jmp    80104bde <scheduler+0x1b>

80104c71 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104c71:	55                   	push   %ebp
80104c72:	89 e5                	mov    %esp,%ebp
80104c74:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104c77:	e8 63 f8 ff ff       	call   801044df <myproc>
80104c7c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104c7f:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104c86:	e8 62 09 00 00       	call   801055ed <holding>
80104c8b:	85 c0                	test   %eax,%eax
80104c8d:	75 0c                	jne    80104c9b <sched+0x2a>
    panic("sched ptable.lock");
80104c8f:	c7 04 24 b7 9c 10 80 	movl   $0x80109cb7,(%esp)
80104c96:	e8 b9 b8 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104c9b:	e8 bb f7 ff ff       	call   8010445b <mycpu>
80104ca0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ca6:	83 f8 01             	cmp    $0x1,%eax
80104ca9:	74 0c                	je     80104cb7 <sched+0x46>
    panic("sched locks");
80104cab:	c7 04 24 c9 9c 10 80 	movl   $0x80109cc9,(%esp)
80104cb2:	e8 9d b8 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cba:	8b 40 0c             	mov    0xc(%eax),%eax
80104cbd:	83 f8 04             	cmp    $0x4,%eax
80104cc0:	75 0c                	jne    80104cce <sched+0x5d>
    panic("sched running");
80104cc2:	c7 04 24 d5 9c 10 80 	movl   $0x80109cd5,(%esp)
80104cc9:	e8 86 b8 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104cce:	e8 11 f7 ff ff       	call   801043e4 <readeflags>
80104cd3:	25 00 02 00 00       	and    $0x200,%eax
80104cd8:	85 c0                	test   %eax,%eax
80104cda:	74 0c                	je     80104ce8 <sched+0x77>
    panic("sched interruptible");
80104cdc:	c7 04 24 e3 9c 10 80 	movl   $0x80109ce3,(%esp)
80104ce3:	e8 6c b8 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104ce8:	e8 6e f7 ff ff       	call   8010445b <mycpu>
80104ced:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104cf6:	e8 60 f7 ff ff       	call   8010445b <mycpu>
80104cfb:	8b 40 04             	mov    0x4(%eax),%eax
80104cfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d01:	83 c2 1c             	add    $0x1c,%edx
80104d04:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d08:	89 14 24             	mov    %edx,(%esp)
80104d0b:	e8 8c 0c 00 00       	call   8010599c <swtch>
  mycpu()->intena = intena;
80104d10:	e8 46 f7 ff ff       	call   8010445b <mycpu>
80104d15:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d18:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104d1e:	c9                   	leave  
80104d1f:	c3                   	ret    

80104d20 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d20:	55                   	push   %ebp
80104d21:	89 e5                	mov    %esp,%ebp
80104d23:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d26:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104d2d:	e8 8d 07 00 00       	call   801054bf <acquire>
  myproc()->state = RUNNABLE;
80104d32:	e8 a8 f7 ff ff       	call   801044df <myproc>
80104d37:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d3e:	e8 2e ff ff ff       	call   80104c71 <sched>
  release(&ptable.lock);
80104d43:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104d4a:	e8 da 07 00 00       	call   80105529 <release>
}
80104d4f:	c9                   	leave  
80104d50:	c3                   	ret    

80104d51 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d51:	55                   	push   %ebp
80104d52:	89 e5                	mov    %esp,%ebp
80104d54:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d57:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104d5e:	e8 c6 07 00 00       	call   80105529 <release>

  if (first) {
80104d63:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104d68:	85 c0                	test   %eax,%eax
80104d6a:	74 22                	je     80104d8e <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104d6c:	c7 05 04 d0 10 80 00 	movl   $0x0,0x8010d004
80104d73:	00 00 00 
    iinit(ROOTDEV);
80104d76:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104d7d:	e8 d9 c9 ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104d82:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104d89:	e8 52 e8 ff ff       	call   801035e0 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104d8e:	c9                   	leave  
80104d8f:	c3                   	ret    

80104d90 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d90:	55                   	push   %ebp
80104d91:	89 e5                	mov    %esp,%ebp
80104d93:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104d96:	e8 44 f7 ff ff       	call   801044df <myproc>
80104d9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104d9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104da2:	75 0c                	jne    80104db0 <sleep+0x20>
    panic("sleep");
80104da4:	c7 04 24 f7 9c 10 80 	movl   $0x80109cf7,(%esp)
80104dab:	e8 a4 b7 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104db0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104db4:	75 0c                	jne    80104dc2 <sleep+0x32>
    panic("sleep without lk");
80104db6:	c7 04 24 fd 9c 10 80 	movl   $0x80109cfd,(%esp)
80104dbd:	e8 92 b7 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104dc2:	81 7d 0c 40 62 11 80 	cmpl   $0x80116240,0xc(%ebp)
80104dc9:	74 17                	je     80104de2 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104dcb:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104dd2:	e8 e8 06 00 00       	call   801054bf <acquire>
    release(lk);
80104dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dda:	89 04 24             	mov    %eax,(%esp)
80104ddd:	e8 47 07 00 00       	call   80105529 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de5:	8b 55 08             	mov    0x8(%ebp),%edx
80104de8:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dee:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104df5:	e8 77 fe ff ff       	call   80104c71 <sched>

  // Tidy up.
  p->chan = 0;
80104dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dfd:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e04:	81 7d 0c 40 62 11 80 	cmpl   $0x80116240,0xc(%ebp)
80104e0b:	74 17                	je     80104e24 <sleep+0x94>
    release(&ptable.lock);
80104e0d:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104e14:	e8 10 07 00 00       	call   80105529 <release>
    acquire(lk);
80104e19:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e1c:	89 04 24             	mov    %eax,(%esp)
80104e1f:	e8 9b 06 00 00       	call   801054bf <acquire>
  }
}
80104e24:	c9                   	leave  
80104e25:	c3                   	ret    

80104e26 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e26:	55                   	push   %ebp
80104e27:	89 e5                	mov    %esp,%ebp
80104e29:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e2c:	c7 45 fc 74 62 11 80 	movl   $0x80116274,-0x4(%ebp)
80104e33:	eb 27                	jmp    80104e5c <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104e35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e38:	8b 40 0c             	mov    0xc(%eax),%eax
80104e3b:	83 f8 02             	cmp    $0x2,%eax
80104e3e:	75 15                	jne    80104e55 <wakeup1+0x2f>
80104e40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e43:	8b 40 20             	mov    0x20(%eax),%eax
80104e46:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e49:	75 0a                	jne    80104e55 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e4e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e55:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104e5c:	81 7d fc 74 83 11 80 	cmpl   $0x80118374,-0x4(%ebp)
80104e63:	72 d0                	jb     80104e35 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104e65:	c9                   	leave  
80104e66:	c3                   	ret    

80104e67 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e67:	55                   	push   %ebp
80104e68:	89 e5                	mov    %esp,%ebp
80104e6a:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104e6d:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104e74:	e8 46 06 00 00       	call   801054bf <acquire>
  wakeup1(chan);
80104e79:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7c:	89 04 24             	mov    %eax,(%esp)
80104e7f:	e8 a2 ff ff ff       	call   80104e26 <wakeup1>
  release(&ptable.lock);
80104e84:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104e8b:	e8 99 06 00 00       	call   80105529 <release>
}
80104e90:	c9                   	leave  
80104e91:	c3                   	ret    

80104e92 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e92:	55                   	push   %ebp
80104e93:	89 e5                	mov    %esp,%ebp
80104e95:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e98:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104e9f:	e8 1b 06 00 00       	call   801054bf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ea4:	c7 45 f4 74 62 11 80 	movl   $0x80116274,-0xc(%ebp)
80104eab:	eb 44                	jmp    80104ef1 <kill+0x5f>
    if(p->pid == pid){
80104ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb0:	8b 40 10             	mov    0x10(%eax),%eax
80104eb3:	3b 45 08             	cmp    0x8(%ebp),%eax
80104eb6:	75 32                	jne    80104eea <kill+0x58>
      p->killed = 1;
80104eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ec8:	83 f8 02             	cmp    $0x2,%eax
80104ecb:	75 0a                	jne    80104ed7 <kill+0x45>
        p->state = RUNNABLE;
80104ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104ed7:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104ede:	e8 46 06 00 00       	call   80105529 <release>
      return 0;
80104ee3:	b8 00 00 00 00       	mov    $0x0,%eax
80104ee8:	eb 21                	jmp    80104f0b <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eea:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ef1:	81 7d f4 74 83 11 80 	cmpl   $0x80118374,-0xc(%ebp)
80104ef8:	72 b3                	jb     80104ead <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104efa:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80104f01:	e8 23 06 00 00       	call   80105529 <release>
  return -1;
80104f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f0b:	c9                   	leave  
80104f0c:	c3                   	ret    

80104f0d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f0d:	55                   	push   %ebp
80104f0e:	89 e5                	mov    %esp,%ebp
80104f10:	83 ec 68             	sub    $0x68,%esp
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f13:	c7 45 f0 74 62 11 80 	movl   $0x80116274,-0x10(%ebp)
80104f1a:	e9 1e 01 00 00       	jmp    8010503d <procdump+0x130>
    if(p->state == UNUSED)
80104f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f22:	8b 40 0c             	mov    0xc(%eax),%eax
80104f25:	85 c0                	test   %eax,%eax
80104f27:	75 05                	jne    80104f2e <procdump+0x21>
      continue;
80104f29:	e9 08 01 00 00       	jmp    80105036 <procdump+0x129>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f31:	8b 40 0c             	mov    0xc(%eax),%eax
80104f34:	83 f8 05             	cmp    $0x5,%eax
80104f37:	77 23                	ja     80104f5c <procdump+0x4f>
80104f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f3c:	8b 40 0c             	mov    0xc(%eax),%eax
80104f3f:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80104f46:	85 c0                	test   %eax,%eax
80104f48:	74 12                	je     80104f5c <procdump+0x4f>
      state = states[p->state];
80104f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4d:	8b 40 0c             	mov    0xc(%eax),%eax
80104f50:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80104f57:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f5a:	eb 07                	jmp    80104f63 <procdump+0x56>
    else
      state = "???";
80104f5c:	c7 45 ec 0e 9d 10 80 	movl   $0x80109d0e,-0x14(%ebp)

    if(p->cont == NULL){
80104f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f66:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104f6c:	85 c0                	test   %eax,%eax
80104f6e:	75 29                	jne    80104f99 <procdump+0x8c>
      cprintf("%d root %s %s", p->pid, state, p->name);
80104f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f73:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f79:	8b 40 10             	mov    0x10(%eax),%eax
80104f7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f80:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f83:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f87:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f8b:	c7 04 24 12 9d 10 80 	movl   $0x80109d12,(%esp)
80104f92:	e8 2a b4 ff ff       	call   801003c1 <cprintf>
80104f97:	eb 37                	jmp    80104fd0 <procdump+0xc3>
    }
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
80104f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f9c:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fa8:	8d 48 18             	lea    0x18(%eax),%ecx
80104fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fae:	8b 40 10             	mov    0x10(%eax),%eax
80104fb1:	89 54 24 10          	mov    %edx,0x10(%esp)
80104fb5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fb8:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104fbc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80104fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fc4:	c7 04 24 20 9d 10 80 	movl   $0x80109d20,(%esp)
80104fcb:	e8 f1 b3 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
80104fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd3:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd6:	83 f8 02             	cmp    $0x2,%eax
80104fd9:	75 4f                	jne    8010502a <procdump+0x11d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104fdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fde:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fe1:	8b 40 0c             	mov    0xc(%eax),%eax
80104fe4:	83 c0 08             	add    $0x8,%eax
80104fe7:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104fea:	89 54 24 04          	mov    %edx,0x4(%esp)
80104fee:	89 04 24             	mov    %eax,(%esp)
80104ff1:	e8 80 05 00 00       	call   80105576 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104ff6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ffd:	eb 1a                	jmp    80105019 <procdump+0x10c>
        cprintf(" %p", pc[i]);
80104fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105002:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105006:	89 44 24 04          	mov    %eax,0x4(%esp)
8010500a:	c7 04 24 2c 9d 10 80 	movl   $0x80109d2c,(%esp)
80105011:	e8 ab b3 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105016:	ff 45 f4             	incl   -0xc(%ebp)
80105019:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010501d:	7f 0b                	jg     8010502a <procdump+0x11d>
8010501f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105022:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105026:	85 c0                	test   %eax,%eax
80105028:	75 d5                	jne    80104fff <procdump+0xf2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010502a:	c7 04 24 30 9d 10 80 	movl   $0x80109d30,(%esp)
80105031:	e8 8b b3 ff ff       	call   801003c1 <cprintf>
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105036:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
8010503d:	81 7d f0 74 83 11 80 	cmpl   $0x80118374,-0x10(%ebp)
80105044:	0f 82 d5 fe ff ff    	jb     80104f1f <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010504a:	c9                   	leave  
8010504b:	c3                   	ret    

8010504c <cstop_container_helper>:


void cstop_container_helper(struct container* cont){
8010504c:	55                   	push   %ebp
8010504d:	89 e5                	mov    %esp,%ebp
8010504f:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105052:	c7 45 f4 74 62 11 80 	movl   $0x80116274,-0xc(%ebp)
80105059:	eb 37                	jmp    80105092 <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
8010505b:	8b 45 08             	mov    0x8(%ebp),%eax
8010505e:	8d 50 18             	lea    0x18(%eax),%edx
80105061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105064:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010506a:	83 c0 18             	add    $0x18,%eax
8010506d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105071:	89 04 24             	mov    %eax,(%esp)
80105074:	e8 03 fa ff ff       	call   80104a7c <strcmp1>
80105079:	85 c0                	test   %eax,%eax
8010507b:	75 0e                	jne    8010508b <cstop_container_helper+0x3f>
      kill(p->pid);
8010507d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105080:	8b 40 10             	mov    0x10(%eax),%eax
80105083:	89 04 24             	mov    %eax,(%esp)
80105086:	e8 07 fe ff ff       	call   80104e92 <kill>


void cstop_container_helper(struct container* cont){

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010508b:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80105092:	81 7d f4 74 83 11 80 	cmpl   $0x80118374,-0xc(%ebp)
80105099:	72 c0                	jb     8010505b <cstop_container_helper+0xf>
    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }

  container_reset(find(cont->name));
8010509b:	8b 45 08             	mov    0x8(%ebp),%eax
8010509e:	83 c0 18             	add    $0x18,%eax
801050a1:	89 04 24             	mov    %eax,(%esp)
801050a4:	e8 c2 40 00 00       	call   8010916b <find>
801050a9:	89 04 24             	mov    %eax,(%esp)
801050ac:	e8 fe 46 00 00       	call   801097af <container_reset>
}
801050b1:	c9                   	leave  
801050b2:	c3                   	ret    

801050b3 <cstop_helper>:

void cstop_helper(char* name){
801050b3:	55                   	push   %ebp
801050b4:	89 e5                	mov    %esp,%ebp
801050b6:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050b9:	c7 45 f4 74 62 11 80 	movl   $0x80116274,-0xc(%ebp)
801050c0:	eb 69                	jmp    8010512b <cstop_helper+0x78>

    if(p->cont == NULL){
801050c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801050cb:	85 c0                	test   %eax,%eax
801050cd:	75 02                	jne    801050d1 <cstop_helper+0x1e>
      continue;
801050cf:	eb 53                	jmp    80105124 <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
801050d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801050da:	8d 50 18             	lea    0x18(%eax),%edx
801050dd:	8b 45 08             	mov    0x8(%ebp),%eax
801050e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801050e4:	89 14 24             	mov    %edx,(%esp)
801050e7:	e8 90 f9 ff ff       	call   80104a7c <strcmp1>
801050ec:	85 c0                	test   %eax,%eax
801050ee:	75 34                	jne    80105124 <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
801050f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f3:	8b 40 10             	mov    0x10(%eax),%eax
801050f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050f9:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
801050ff:	83 c2 18             	add    $0x18,%edx
80105102:	89 44 24 08          	mov    %eax,0x8(%esp)
80105106:	89 54 24 04          	mov    %edx,0x4(%esp)
8010510a:	c7 04 24 34 9d 10 80 	movl   $0x80109d34,(%esp)
80105111:	e8 ab b2 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
80105116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105119:	8b 40 10             	mov    0x10(%eax),%eax
8010511c:	89 04 24             	mov    %eax,(%esp)
8010511f:	e8 6e fd ff ff       	call   80104e92 <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105124:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010512b:	81 7d f4 74 83 11 80 	cmpl   $0x80118374,-0xc(%ebp)
80105132:	72 8e                	jb     801050c2 <cstop_helper+0xf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
      kill(p->pid);
    }
  }
  container_reset(find(name));
80105134:	8b 45 08             	mov    0x8(%ebp),%eax
80105137:	89 04 24             	mov    %eax,(%esp)
8010513a:	e8 2c 40 00 00       	call   8010916b <find>
8010513f:	89 04 24             	mov    %eax,(%esp)
80105142:	e8 68 46 00 00       	call   801097af <container_reset>
}
80105147:	c9                   	leave  
80105148:	c3                   	ret    

80105149 <c_procdump>:

void
c_procdump(char* name)
{
80105149:	55                   	push   %ebp
8010514a:	89 e5                	mov    %esp,%ebp
8010514c:	83 ec 68             	sub    $0x68,%esp
  char *state;
  uint pc[10];



  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010514f:	c7 45 f0 74 62 11 80 	movl   $0x80116274,-0x10(%ebp)
80105156:	e9 25 01 00 00       	jmp    80105280 <c_procdump+0x137>
    if(p->state == UNUSED || p->cont == NULL)
8010515b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010515e:	8b 40 0c             	mov    0xc(%eax),%eax
80105161:	85 c0                	test   %eax,%eax
80105163:	74 0d                	je     80105172 <c_procdump+0x29>
80105165:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105168:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010516e:	85 c0                	test   %eax,%eax
80105170:	75 05                	jne    80105177 <c_procdump+0x2e>
      continue;
80105172:	e9 02 01 00 00       	jmp    80105279 <c_procdump+0x130>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010517a:	8b 40 0c             	mov    0xc(%eax),%eax
8010517d:	83 f8 05             	cmp    $0x5,%eax
80105180:	77 23                	ja     801051a5 <c_procdump+0x5c>
80105182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105185:	8b 40 0c             	mov    0xc(%eax),%eax
80105188:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
8010518f:	85 c0                	test   %eax,%eax
80105191:	74 12                	je     801051a5 <c_procdump+0x5c>
      state = states[p->state];
80105193:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105196:	8b 40 0c             	mov    0xc(%eax),%eax
80105199:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
801051a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801051a3:	eb 07                	jmp    801051ac <c_procdump+0x63>
    else
      state = "???";
801051a5:	c7 45 ec 0e 9d 10 80 	movl   $0x80109d0e,-0x14(%ebp)

    if(strcmp1(p->cont->name, name) == 0){
801051ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051af:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801051b5:	8d 50 18             	lea    0x18(%eax),%edx
801051b8:	8b 45 08             	mov    0x8(%ebp),%eax
801051bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801051bf:	89 14 24             	mov    %edx,(%esp)
801051c2:	e8 b5 f8 ff ff       	call   80104a7c <strcmp1>
801051c7:	85 c0                	test   %eax,%eax
801051c9:	0f 85 aa 00 00 00    	jne    80105279 <c_procdump+0x130>
      cprintf("STATE: %d \n", p->state);
801051cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d2:	8b 40 0c             	mov    0xc(%eax),%eax
801051d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801051d9:	c7 04 24 54 9d 10 80 	movl   $0x80109d54,(%esp)
801051e0:	e8 dc b1 ff ff       	call   801003c1 <cprintf>
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
801051e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e8:	8d 50 6c             	lea    0x6c(%eax),%edx
801051eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ee:	8b 40 10             	mov    0x10(%eax),%eax
801051f1:	89 54 24 10          	mov    %edx,0x10(%esp)
801051f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
801051fc:	8b 55 08             	mov    0x8(%ebp),%edx
801051ff:	89 54 24 08          	mov    %edx,0x8(%esp)
80105203:	89 44 24 04          	mov    %eax,0x4(%esp)
80105207:	c7 04 24 20 9d 10 80 	movl   $0x80109d20,(%esp)
8010520e:	e8 ae b1 ff ff       	call   801003c1 <cprintf>
      if(p->state == SLEEPING){
80105213:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105216:	8b 40 0c             	mov    0xc(%eax),%eax
80105219:	83 f8 02             	cmp    $0x2,%eax
8010521c:	75 4f                	jne    8010526d <c_procdump+0x124>
        getcallerpcs((uint*)p->context->ebp+2, pc);
8010521e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105221:	8b 40 1c             	mov    0x1c(%eax),%eax
80105224:	8b 40 0c             	mov    0xc(%eax),%eax
80105227:	83 c0 08             	add    $0x8,%eax
8010522a:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010522d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105231:	89 04 24             	mov    %eax,(%esp)
80105234:	e8 3d 03 00 00       	call   80105576 <getcallerpcs>
        for(i=0; i<10 && pc[i] != 0; i++)
80105239:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105240:	eb 1a                	jmp    8010525c <c_procdump+0x113>
          cprintf(" %p", pc[i]);
80105242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105245:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105249:	89 44 24 04          	mov    %eax,0x4(%esp)
8010524d:	c7 04 24 2c 9d 10 80 	movl   $0x80109d2c,(%esp)
80105254:	e8 68 b1 ff ff       	call   801003c1 <cprintf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("STATE: %d \n", p->state);
      cprintf("%d %s %s %s", p->pid, name, state, p->name);
      if(p->state == SLEEPING){
        getcallerpcs((uint*)p->context->ebp+2, pc);
        for(i=0; i<10 && pc[i] != 0; i++)
80105259:	ff 45 f4             	incl   -0xc(%ebp)
8010525c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105260:	7f 0b                	jg     8010526d <c_procdump+0x124>
80105262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105265:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105269:	85 c0                	test   %eax,%eax
8010526b:	75 d5                	jne    80105242 <c_procdump+0xf9>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
8010526d:	c7 04 24 30 9d 10 80 	movl   $0x80109d30,(%esp)
80105274:	e8 48 b1 ff ff       	call   801003c1 <cprintf>
  char *state;
  uint pc[10];



  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105279:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80105280:	81 7d f0 74 83 11 80 	cmpl   $0x80118374,-0x10(%ebp)
80105287:	0f 82 ce fe ff ff    	jb     8010515b <c_procdump+0x12>
          cprintf(" %p", pc[i]);
      }
      cprintf("\n");
    }  
  }
}
8010528d:	c9                   	leave  
8010528e:	c3                   	ret    

8010528f <pause>:

void
pause(char* name)
{
8010528f:	55                   	push   %ebp
80105290:	89 e5                	mov    %esp,%ebp
80105292:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105295:	c7 45 fc 74 62 11 80 	movl   $0x80116274,-0x4(%ebp)
8010529c:	eb 49                	jmp    801052e7 <pause+0x58>
    if(p->state == UNUSED || p->cont == NULL)
8010529e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052a1:	8b 40 0c             	mov    0xc(%eax),%eax
801052a4:	85 c0                	test   %eax,%eax
801052a6:	74 0d                	je     801052b5 <pause+0x26>
801052a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052ab:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052b1:	85 c0                	test   %eax,%eax
801052b3:	75 02                	jne    801052b7 <pause+0x28>
      continue;
801052b5:	eb 29                	jmp    801052e0 <pause+0x51>
    if(strcmp1(p->cont->name, name) == 0){
801052b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052ba:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052c0:	8d 50 18             	lea    0x18(%eax),%edx
801052c3:	8b 45 08             	mov    0x8(%ebp),%eax
801052c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801052ca:	89 14 24             	mov    %edx,(%esp)
801052cd:	e8 aa f7 ff ff       	call   80104a7c <strcmp1>
801052d2:	85 c0                	test   %eax,%eax
801052d4:	75 0a                	jne    801052e0 <pause+0x51>
      p->state = ZOMBIE;
801052d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052d9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
void
pause(char* name)
{
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052e0:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801052e7:	81 7d fc 74 83 11 80 	cmpl   $0x80118374,-0x4(%ebp)
801052ee:	72 ae                	jb     8010529e <pause+0xf>
      continue;
    if(strcmp1(p->cont->name, name) == 0){
      p->state = ZOMBIE;
    }
  }
}
801052f0:	c9                   	leave  
801052f1:	c3                   	ret    

801052f2 <resume>:

void
resume(char* name)
{
801052f2:	55                   	push   %ebp
801052f3:	89 e5                	mov    %esp,%ebp
801052f5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052f8:	c7 45 fc 74 62 11 80 	movl   $0x80116274,-0x4(%ebp)
801052ff:	eb 3b                	jmp    8010533c <resume+0x4a>
    if(p->state == ZOMBIE){
80105301:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105304:	8b 40 0c             	mov    0xc(%eax),%eax
80105307:	83 f8 05             	cmp    $0x5,%eax
8010530a:	75 29                	jne    80105335 <resume+0x43>
      if(strcmp1(p->cont->name, name) == 0){
8010530c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010530f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105315:	8d 50 18             	lea    0x18(%eax),%edx
80105318:	8b 45 08             	mov    0x8(%ebp),%eax
8010531b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010531f:	89 14 24             	mov    %edx,(%esp)
80105322:	e8 55 f7 ff ff       	call   80104a7c <strcmp1>
80105327:	85 c0                	test   %eax,%eax
80105329:	75 0a                	jne    80105335 <resume+0x43>
        p->state = RUNNABLE;
8010532b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010532e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
void
resume(char* name)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105335:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
8010533c:	81 7d fc 74 83 11 80 	cmpl   $0x80118374,-0x4(%ebp)
80105343:	72 bc                	jb     80105301 <resume+0xf>
      if(strcmp1(p->cont->name, name) == 0){
        p->state = RUNNABLE;
      }
    }
  }
}
80105345:	c9                   	leave  
80105346:	c3                   	ret    

80105347 <initp>:


struct proc* initp(void){
80105347:	55                   	push   %ebp
80105348:	89 e5                	mov    %esp,%ebp
  return initproc;
8010534a:	a1 20 d9 10 80       	mov    0x8010d920,%eax
}
8010534f:	5d                   	pop    %ebp
80105350:	c3                   	ret    

80105351 <c_proc>:

struct proc* c_proc(void){
80105351:	55                   	push   %ebp
80105352:	89 e5                	mov    %esp,%ebp
80105354:	83 ec 08             	sub    $0x8,%esp
  return myproc();
80105357:	e8 83 f1 ff ff       	call   801044df <myproc>
}
8010535c:	c9                   	leave  
8010535d:	c3                   	ret    
	...

80105360 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105360:	55                   	push   %ebp
80105361:	89 e5                	mov    %esp,%ebp
80105363:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80105366:	8b 45 08             	mov    0x8(%ebp),%eax
80105369:	83 c0 04             	add    $0x4,%eax
8010536c:	c7 44 24 04 8a 9d 10 	movl   $0x80109d8a,0x4(%esp)
80105373:	80 
80105374:	89 04 24             	mov    %eax,(%esp)
80105377:	e8 22 01 00 00       	call   8010549e <initlock>
  lk->name = name;
8010537c:	8b 45 08             	mov    0x8(%ebp),%eax
8010537f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105382:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105385:	8b 45 08             	mov    0x8(%ebp),%eax
80105388:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010538e:	8b 45 08             	mov    0x8(%ebp),%eax
80105391:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105398:	c9                   	leave  
80105399:	c3                   	ret    

8010539a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010539a:	55                   	push   %ebp
8010539b:	89 e5                	mov    %esp,%ebp
8010539d:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801053a0:	8b 45 08             	mov    0x8(%ebp),%eax
801053a3:	83 c0 04             	add    $0x4,%eax
801053a6:	89 04 24             	mov    %eax,(%esp)
801053a9:	e8 11 01 00 00       	call   801054bf <acquire>
  while (lk->locked) {
801053ae:	eb 15                	jmp    801053c5 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
801053b0:	8b 45 08             	mov    0x8(%ebp),%eax
801053b3:	83 c0 04             	add    $0x4,%eax
801053b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801053ba:	8b 45 08             	mov    0x8(%ebp),%eax
801053bd:	89 04 24             	mov    %eax,(%esp)
801053c0:	e8 cb f9 ff ff       	call   80104d90 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
801053c5:	8b 45 08             	mov    0x8(%ebp),%eax
801053c8:	8b 00                	mov    (%eax),%eax
801053ca:	85 c0                	test   %eax,%eax
801053cc:	75 e2                	jne    801053b0 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
801053ce:	8b 45 08             	mov    0x8(%ebp),%eax
801053d1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801053d7:	e8 03 f1 ff ff       	call   801044df <myproc>
801053dc:	8b 50 10             	mov    0x10(%eax),%edx
801053df:	8b 45 08             	mov    0x8(%ebp),%eax
801053e2:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801053e5:	8b 45 08             	mov    0x8(%ebp),%eax
801053e8:	83 c0 04             	add    $0x4,%eax
801053eb:	89 04 24             	mov    %eax,(%esp)
801053ee:	e8 36 01 00 00       	call   80105529 <release>
}
801053f3:	c9                   	leave  
801053f4:	c3                   	ret    

801053f5 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801053f5:	55                   	push   %ebp
801053f6:	89 e5                	mov    %esp,%ebp
801053f8:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801053fb:	8b 45 08             	mov    0x8(%ebp),%eax
801053fe:	83 c0 04             	add    $0x4,%eax
80105401:	89 04 24             	mov    %eax,(%esp)
80105404:	e8 b6 00 00 00       	call   801054bf <acquire>
  lk->locked = 0;
80105409:	8b 45 08             	mov    0x8(%ebp),%eax
8010540c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105412:	8b 45 08             	mov    0x8(%ebp),%eax
80105415:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010541c:	8b 45 08             	mov    0x8(%ebp),%eax
8010541f:	89 04 24             	mov    %eax,(%esp)
80105422:	e8 40 fa ff ff       	call   80104e67 <wakeup>
  release(&lk->lk);
80105427:	8b 45 08             	mov    0x8(%ebp),%eax
8010542a:	83 c0 04             	add    $0x4,%eax
8010542d:	89 04 24             	mov    %eax,(%esp)
80105430:	e8 f4 00 00 00       	call   80105529 <release>
}
80105435:	c9                   	leave  
80105436:	c3                   	ret    

80105437 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105437:	55                   	push   %ebp
80105438:	89 e5                	mov    %esp,%ebp
8010543a:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
8010543d:	8b 45 08             	mov    0x8(%ebp),%eax
80105440:	83 c0 04             	add    $0x4,%eax
80105443:	89 04 24             	mov    %eax,(%esp)
80105446:	e8 74 00 00 00       	call   801054bf <acquire>
  r = lk->locked;
8010544b:	8b 45 08             	mov    0x8(%ebp),%eax
8010544e:	8b 00                	mov    (%eax),%eax
80105450:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105453:	8b 45 08             	mov    0x8(%ebp),%eax
80105456:	83 c0 04             	add    $0x4,%eax
80105459:	89 04 24             	mov    %eax,(%esp)
8010545c:	e8 c8 00 00 00       	call   80105529 <release>
  return r;
80105461:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105464:	c9                   	leave  
80105465:	c3                   	ret    
	...

80105468 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105468:	55                   	push   %ebp
80105469:	89 e5                	mov    %esp,%ebp
8010546b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010546e:	9c                   	pushf  
8010546f:	58                   	pop    %eax
80105470:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105473:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105476:	c9                   	leave  
80105477:	c3                   	ret    

80105478 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105478:	55                   	push   %ebp
80105479:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010547b:	fa                   	cli    
}
8010547c:	5d                   	pop    %ebp
8010547d:	c3                   	ret    

8010547e <sti>:

static inline void
sti(void)
{
8010547e:	55                   	push   %ebp
8010547f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105481:	fb                   	sti    
}
80105482:	5d                   	pop    %ebp
80105483:	c3                   	ret    

80105484 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105484:	55                   	push   %ebp
80105485:	89 e5                	mov    %esp,%ebp
80105487:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010548a:	8b 55 08             	mov    0x8(%ebp),%edx
8010548d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105490:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105493:	f0 87 02             	lock xchg %eax,(%edx)
80105496:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105499:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010549c:	c9                   	leave  
8010549d:	c3                   	ret    

8010549e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010549e:	55                   	push   %ebp
8010549f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801054a1:	8b 45 08             	mov    0x8(%ebp),%eax
801054a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801054a7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801054aa:	8b 45 08             	mov    0x8(%ebp),%eax
801054ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801054b3:	8b 45 08             	mov    0x8(%ebp),%eax
801054b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801054bd:	5d                   	pop    %ebp
801054be:	c3                   	ret    

801054bf <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801054bf:	55                   	push   %ebp
801054c0:	89 e5                	mov    %esp,%ebp
801054c2:	53                   	push   %ebx
801054c3:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801054c6:	e8 53 01 00 00       	call   8010561e <pushcli>
  if(holding(lk))
801054cb:	8b 45 08             	mov    0x8(%ebp),%eax
801054ce:	89 04 24             	mov    %eax,(%esp)
801054d1:	e8 17 01 00 00       	call   801055ed <holding>
801054d6:	85 c0                	test   %eax,%eax
801054d8:	74 0c                	je     801054e6 <acquire+0x27>
    panic("acquire");
801054da:	c7 04 24 95 9d 10 80 	movl   $0x80109d95,(%esp)
801054e1:	e8 6e b0 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801054e6:	90                   	nop
801054e7:	8b 45 08             	mov    0x8(%ebp),%eax
801054ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801054f1:	00 
801054f2:	89 04 24             	mov    %eax,(%esp)
801054f5:	e8 8a ff ff ff       	call   80105484 <xchg>
801054fa:	85 c0                	test   %eax,%eax
801054fc:	75 e9                	jne    801054e7 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801054fe:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105503:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105506:	e8 50 ef ff ff       	call   8010445b <mycpu>
8010550b:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010550e:	8b 45 08             	mov    0x8(%ebp),%eax
80105511:	83 c0 0c             	add    $0xc,%eax
80105514:	89 44 24 04          	mov    %eax,0x4(%esp)
80105518:	8d 45 08             	lea    0x8(%ebp),%eax
8010551b:	89 04 24             	mov    %eax,(%esp)
8010551e:	e8 53 00 00 00       	call   80105576 <getcallerpcs>
}
80105523:	83 c4 14             	add    $0x14,%esp
80105526:	5b                   	pop    %ebx
80105527:	5d                   	pop    %ebp
80105528:	c3                   	ret    

80105529 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105529:	55                   	push   %ebp
8010552a:	89 e5                	mov    %esp,%ebp
8010552c:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010552f:	8b 45 08             	mov    0x8(%ebp),%eax
80105532:	89 04 24             	mov    %eax,(%esp)
80105535:	e8 b3 00 00 00       	call   801055ed <holding>
8010553a:	85 c0                	test   %eax,%eax
8010553c:	75 0c                	jne    8010554a <release+0x21>
    panic("release");
8010553e:	c7 04 24 9d 9d 10 80 	movl   $0x80109d9d,(%esp)
80105545:	e8 0a b0 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
8010554a:	8b 45 08             	mov    0x8(%ebp),%eax
8010554d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105554:	8b 45 08             	mov    0x8(%ebp),%eax
80105557:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010555e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105563:	8b 45 08             	mov    0x8(%ebp),%eax
80105566:	8b 55 08             	mov    0x8(%ebp),%edx
80105569:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010556f:	e8 f4 00 00 00       	call   80105668 <popcli>
}
80105574:	c9                   	leave  
80105575:	c3                   	ret    

80105576 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105576:	55                   	push   %ebp
80105577:	89 e5                	mov    %esp,%ebp
80105579:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010557c:	8b 45 08             	mov    0x8(%ebp),%eax
8010557f:	83 e8 08             	sub    $0x8,%eax
80105582:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105585:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010558c:	eb 37                	jmp    801055c5 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010558e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105592:	74 37                	je     801055cb <getcallerpcs+0x55>
80105594:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010559b:	76 2e                	jbe    801055cb <getcallerpcs+0x55>
8010559d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801055a1:	74 28                	je     801055cb <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
801055a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801055ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b0:	01 c2                	add    %eax,%edx
801055b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b5:	8b 40 04             	mov    0x4(%eax),%eax
801055b8:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801055ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055bd:	8b 00                	mov    (%eax),%eax
801055bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801055c2:	ff 45 f8             	incl   -0x8(%ebp)
801055c5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801055c9:	7e c3                	jle    8010558e <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801055cb:	eb 18                	jmp    801055e5 <getcallerpcs+0x6f>
    pcs[i] = 0;
801055cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801055d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055da:	01 d0                	add    %edx,%eax
801055dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801055e2:	ff 45 f8             	incl   -0x8(%ebp)
801055e5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801055e9:	7e e2                	jle    801055cd <getcallerpcs+0x57>
    pcs[i] = 0;
}
801055eb:	c9                   	leave  
801055ec:	c3                   	ret    

801055ed <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801055ed:	55                   	push   %ebp
801055ee:	89 e5                	mov    %esp,%ebp
801055f0:	53                   	push   %ebx
801055f1:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801055f4:	8b 45 08             	mov    0x8(%ebp),%eax
801055f7:	8b 00                	mov    (%eax),%eax
801055f9:	85 c0                	test   %eax,%eax
801055fb:	74 16                	je     80105613 <holding+0x26>
801055fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105600:	8b 58 08             	mov    0x8(%eax),%ebx
80105603:	e8 53 ee ff ff       	call   8010445b <mycpu>
80105608:	39 c3                	cmp    %eax,%ebx
8010560a:	75 07                	jne    80105613 <holding+0x26>
8010560c:	b8 01 00 00 00       	mov    $0x1,%eax
80105611:	eb 05                	jmp    80105618 <holding+0x2b>
80105613:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105618:	83 c4 04             	add    $0x4,%esp
8010561b:	5b                   	pop    %ebx
8010561c:	5d                   	pop    %ebp
8010561d:	c3                   	ret    

8010561e <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010561e:	55                   	push   %ebp
8010561f:	89 e5                	mov    %esp,%ebp
80105621:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105624:	e8 3f fe ff ff       	call   80105468 <readeflags>
80105629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010562c:	e8 47 fe ff ff       	call   80105478 <cli>
  if(mycpu()->ncli == 0)
80105631:	e8 25 ee ff ff       	call   8010445b <mycpu>
80105636:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010563c:	85 c0                	test   %eax,%eax
8010563e:	75 14                	jne    80105654 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105640:	e8 16 ee ff ff       	call   8010445b <mycpu>
80105645:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105648:	81 e2 00 02 00 00    	and    $0x200,%edx
8010564e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105654:	e8 02 ee ff ff       	call   8010445b <mycpu>
80105659:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010565f:	42                   	inc    %edx
80105660:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105666:	c9                   	leave  
80105667:	c3                   	ret    

80105668 <popcli>:

void
popcli(void)
{
80105668:	55                   	push   %ebp
80105669:	89 e5                	mov    %esp,%ebp
8010566b:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010566e:	e8 f5 fd ff ff       	call   80105468 <readeflags>
80105673:	25 00 02 00 00       	and    $0x200,%eax
80105678:	85 c0                	test   %eax,%eax
8010567a:	74 0c                	je     80105688 <popcli+0x20>
    panic("popcli - interruptible");
8010567c:	c7 04 24 a5 9d 10 80 	movl   $0x80109da5,(%esp)
80105683:	e8 cc ae ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105688:	e8 ce ed ff ff       	call   8010445b <mycpu>
8010568d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105693:	4a                   	dec    %edx
80105694:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010569a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801056a0:	85 c0                	test   %eax,%eax
801056a2:	79 0c                	jns    801056b0 <popcli+0x48>
    panic("popcli");
801056a4:	c7 04 24 bc 9d 10 80 	movl   $0x80109dbc,(%esp)
801056ab:	e8 a4 ae ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801056b0:	e8 a6 ed ff ff       	call   8010445b <mycpu>
801056b5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801056bb:	85 c0                	test   %eax,%eax
801056bd:	75 14                	jne    801056d3 <popcli+0x6b>
801056bf:	e8 97 ed ff ff       	call   8010445b <mycpu>
801056c4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801056ca:	85 c0                	test   %eax,%eax
801056cc:	74 05                	je     801056d3 <popcli+0x6b>
    sti();
801056ce:	e8 ab fd ff ff       	call   8010547e <sti>
}
801056d3:	c9                   	leave  
801056d4:	c3                   	ret    
801056d5:	00 00                	add    %al,(%eax)
	...

801056d8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801056d8:	55                   	push   %ebp
801056d9:	89 e5                	mov    %esp,%ebp
801056db:	57                   	push   %edi
801056dc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801056dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
801056e0:	8b 55 10             	mov    0x10(%ebp),%edx
801056e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e6:	89 cb                	mov    %ecx,%ebx
801056e8:	89 df                	mov    %ebx,%edi
801056ea:	89 d1                	mov    %edx,%ecx
801056ec:	fc                   	cld    
801056ed:	f3 aa                	rep stos %al,%es:(%edi)
801056ef:	89 ca                	mov    %ecx,%edx
801056f1:	89 fb                	mov    %edi,%ebx
801056f3:	89 5d 08             	mov    %ebx,0x8(%ebp)
801056f6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801056f9:	5b                   	pop    %ebx
801056fa:	5f                   	pop    %edi
801056fb:	5d                   	pop    %ebp
801056fc:	c3                   	ret    

801056fd <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801056fd:	55                   	push   %ebp
801056fe:	89 e5                	mov    %esp,%ebp
80105700:	57                   	push   %edi
80105701:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105702:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105705:	8b 55 10             	mov    0x10(%ebp),%edx
80105708:	8b 45 0c             	mov    0xc(%ebp),%eax
8010570b:	89 cb                	mov    %ecx,%ebx
8010570d:	89 df                	mov    %ebx,%edi
8010570f:	89 d1                	mov    %edx,%ecx
80105711:	fc                   	cld    
80105712:	f3 ab                	rep stos %eax,%es:(%edi)
80105714:	89 ca                	mov    %ecx,%edx
80105716:	89 fb                	mov    %edi,%ebx
80105718:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010571b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010571e:	5b                   	pop    %ebx
8010571f:	5f                   	pop    %edi
80105720:	5d                   	pop    %ebp
80105721:	c3                   	ret    

80105722 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105722:	55                   	push   %ebp
80105723:	89 e5                	mov    %esp,%ebp
80105725:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105728:	8b 45 08             	mov    0x8(%ebp),%eax
8010572b:	83 e0 03             	and    $0x3,%eax
8010572e:	85 c0                	test   %eax,%eax
80105730:	75 49                	jne    8010577b <memset+0x59>
80105732:	8b 45 10             	mov    0x10(%ebp),%eax
80105735:	83 e0 03             	and    $0x3,%eax
80105738:	85 c0                	test   %eax,%eax
8010573a:	75 3f                	jne    8010577b <memset+0x59>
    c &= 0xFF;
8010573c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105743:	8b 45 10             	mov    0x10(%ebp),%eax
80105746:	c1 e8 02             	shr    $0x2,%eax
80105749:	89 c2                	mov    %eax,%edx
8010574b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010574e:	c1 e0 18             	shl    $0x18,%eax
80105751:	89 c1                	mov    %eax,%ecx
80105753:	8b 45 0c             	mov    0xc(%ebp),%eax
80105756:	c1 e0 10             	shl    $0x10,%eax
80105759:	09 c1                	or     %eax,%ecx
8010575b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010575e:	c1 e0 08             	shl    $0x8,%eax
80105761:	09 c8                	or     %ecx,%eax
80105763:	0b 45 0c             	or     0xc(%ebp),%eax
80105766:	89 54 24 08          	mov    %edx,0x8(%esp)
8010576a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010576e:	8b 45 08             	mov    0x8(%ebp),%eax
80105771:	89 04 24             	mov    %eax,(%esp)
80105774:	e8 84 ff ff ff       	call   801056fd <stosl>
80105779:	eb 19                	jmp    80105794 <memset+0x72>
  } else
    stosb(dst, c, n);
8010577b:	8b 45 10             	mov    0x10(%ebp),%eax
8010577e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105782:	8b 45 0c             	mov    0xc(%ebp),%eax
80105785:	89 44 24 04          	mov    %eax,0x4(%esp)
80105789:	8b 45 08             	mov    0x8(%ebp),%eax
8010578c:	89 04 24             	mov    %eax,(%esp)
8010578f:	e8 44 ff ff ff       	call   801056d8 <stosb>
  return dst;
80105794:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105797:	c9                   	leave  
80105798:	c3                   	ret    

80105799 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105799:	55                   	push   %ebp
8010579a:	89 e5                	mov    %esp,%ebp
8010579c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010579f:	8b 45 08             	mov    0x8(%ebp),%eax
801057a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801057a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801057ab:	eb 2a                	jmp    801057d7 <memcmp+0x3e>
    if(*s1 != *s2)
801057ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057b0:	8a 10                	mov    (%eax),%dl
801057b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057b5:	8a 00                	mov    (%eax),%al
801057b7:	38 c2                	cmp    %al,%dl
801057b9:	74 16                	je     801057d1 <memcmp+0x38>
      return *s1 - *s2;
801057bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057be:	8a 00                	mov    (%eax),%al
801057c0:	0f b6 d0             	movzbl %al,%edx
801057c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057c6:	8a 00                	mov    (%eax),%al
801057c8:	0f b6 c0             	movzbl %al,%eax
801057cb:	29 c2                	sub    %eax,%edx
801057cd:	89 d0                	mov    %edx,%eax
801057cf:	eb 18                	jmp    801057e9 <memcmp+0x50>
    s1++, s2++;
801057d1:	ff 45 fc             	incl   -0x4(%ebp)
801057d4:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801057d7:	8b 45 10             	mov    0x10(%ebp),%eax
801057da:	8d 50 ff             	lea    -0x1(%eax),%edx
801057dd:	89 55 10             	mov    %edx,0x10(%ebp)
801057e0:	85 c0                	test   %eax,%eax
801057e2:	75 c9                	jne    801057ad <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801057e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057e9:	c9                   	leave  
801057ea:	c3                   	ret    

801057eb <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801057eb:	55                   	push   %ebp
801057ec:	89 e5                	mov    %esp,%ebp
801057ee:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801057f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801057f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801057f7:	8b 45 08             	mov    0x8(%ebp),%eax
801057fa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801057fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105800:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105803:	73 3a                	jae    8010583f <memmove+0x54>
80105805:	8b 45 10             	mov    0x10(%ebp),%eax
80105808:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010580b:	01 d0                	add    %edx,%eax
8010580d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105810:	76 2d                	jbe    8010583f <memmove+0x54>
    s += n;
80105812:	8b 45 10             	mov    0x10(%ebp),%eax
80105815:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105818:	8b 45 10             	mov    0x10(%ebp),%eax
8010581b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010581e:	eb 10                	jmp    80105830 <memmove+0x45>
      *--d = *--s;
80105820:	ff 4d f8             	decl   -0x8(%ebp)
80105823:	ff 4d fc             	decl   -0x4(%ebp)
80105826:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105829:	8a 10                	mov    (%eax),%dl
8010582b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010582e:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105830:	8b 45 10             	mov    0x10(%ebp),%eax
80105833:	8d 50 ff             	lea    -0x1(%eax),%edx
80105836:	89 55 10             	mov    %edx,0x10(%ebp)
80105839:	85 c0                	test   %eax,%eax
8010583b:	75 e3                	jne    80105820 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010583d:	eb 25                	jmp    80105864 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010583f:	eb 16                	jmp    80105857 <memmove+0x6c>
      *d++ = *s++;
80105841:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105844:	8d 50 01             	lea    0x1(%eax),%edx
80105847:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010584a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010584d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105850:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105853:	8a 12                	mov    (%edx),%dl
80105855:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105857:	8b 45 10             	mov    0x10(%ebp),%eax
8010585a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010585d:	89 55 10             	mov    %edx,0x10(%ebp)
80105860:	85 c0                	test   %eax,%eax
80105862:	75 dd                	jne    80105841 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105864:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105867:	c9                   	leave  
80105868:	c3                   	ret    

80105869 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105869:	55                   	push   %ebp
8010586a:	89 e5                	mov    %esp,%ebp
8010586c:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010586f:	8b 45 10             	mov    0x10(%ebp),%eax
80105872:	89 44 24 08          	mov    %eax,0x8(%esp)
80105876:	8b 45 0c             	mov    0xc(%ebp),%eax
80105879:	89 44 24 04          	mov    %eax,0x4(%esp)
8010587d:	8b 45 08             	mov    0x8(%ebp),%eax
80105880:	89 04 24             	mov    %eax,(%esp)
80105883:	e8 63 ff ff ff       	call   801057eb <memmove>
}
80105888:	c9                   	leave  
80105889:	c3                   	ret    

8010588a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010588a:	55                   	push   %ebp
8010588b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010588d:	eb 09                	jmp    80105898 <strncmp+0xe>
    n--, p++, q++;
8010588f:	ff 4d 10             	decl   0x10(%ebp)
80105892:	ff 45 08             	incl   0x8(%ebp)
80105895:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105898:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010589c:	74 17                	je     801058b5 <strncmp+0x2b>
8010589e:	8b 45 08             	mov    0x8(%ebp),%eax
801058a1:	8a 00                	mov    (%eax),%al
801058a3:	84 c0                	test   %al,%al
801058a5:	74 0e                	je     801058b5 <strncmp+0x2b>
801058a7:	8b 45 08             	mov    0x8(%ebp),%eax
801058aa:	8a 10                	mov    (%eax),%dl
801058ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801058af:	8a 00                	mov    (%eax),%al
801058b1:	38 c2                	cmp    %al,%dl
801058b3:	74 da                	je     8010588f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801058b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058b9:	75 07                	jne    801058c2 <strncmp+0x38>
    return 0;
801058bb:	b8 00 00 00 00       	mov    $0x0,%eax
801058c0:	eb 14                	jmp    801058d6 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
801058c2:	8b 45 08             	mov    0x8(%ebp),%eax
801058c5:	8a 00                	mov    (%eax),%al
801058c7:	0f b6 d0             	movzbl %al,%edx
801058ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801058cd:	8a 00                	mov    (%eax),%al
801058cf:	0f b6 c0             	movzbl %al,%eax
801058d2:	29 c2                	sub    %eax,%edx
801058d4:	89 d0                	mov    %edx,%eax
}
801058d6:	5d                   	pop    %ebp
801058d7:	c3                   	ret    

801058d8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801058d8:	55                   	push   %ebp
801058d9:	89 e5                	mov    %esp,%ebp
801058db:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801058de:	8b 45 08             	mov    0x8(%ebp),%eax
801058e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801058e4:	90                   	nop
801058e5:	8b 45 10             	mov    0x10(%ebp),%eax
801058e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801058eb:	89 55 10             	mov    %edx,0x10(%ebp)
801058ee:	85 c0                	test   %eax,%eax
801058f0:	7e 1c                	jle    8010590e <strncpy+0x36>
801058f2:	8b 45 08             	mov    0x8(%ebp),%eax
801058f5:	8d 50 01             	lea    0x1(%eax),%edx
801058f8:	89 55 08             	mov    %edx,0x8(%ebp)
801058fb:	8b 55 0c             	mov    0xc(%ebp),%edx
801058fe:	8d 4a 01             	lea    0x1(%edx),%ecx
80105901:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105904:	8a 12                	mov    (%edx),%dl
80105906:	88 10                	mov    %dl,(%eax)
80105908:	8a 00                	mov    (%eax),%al
8010590a:	84 c0                	test   %al,%al
8010590c:	75 d7                	jne    801058e5 <strncpy+0xd>
    ;
  while(n-- > 0)
8010590e:	eb 0c                	jmp    8010591c <strncpy+0x44>
    *s++ = 0;
80105910:	8b 45 08             	mov    0x8(%ebp),%eax
80105913:	8d 50 01             	lea    0x1(%eax),%edx
80105916:	89 55 08             	mov    %edx,0x8(%ebp)
80105919:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010591c:	8b 45 10             	mov    0x10(%ebp),%eax
8010591f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105922:	89 55 10             	mov    %edx,0x10(%ebp)
80105925:	85 c0                	test   %eax,%eax
80105927:	7f e7                	jg     80105910 <strncpy+0x38>
    *s++ = 0;
  return os;
80105929:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010592c:	c9                   	leave  
8010592d:	c3                   	ret    

8010592e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010592e:	55                   	push   %ebp
8010592f:	89 e5                	mov    %esp,%ebp
80105931:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105934:	8b 45 08             	mov    0x8(%ebp),%eax
80105937:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010593a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010593e:	7f 05                	jg     80105945 <safestrcpy+0x17>
    return os;
80105940:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105943:	eb 2e                	jmp    80105973 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105945:	ff 4d 10             	decl   0x10(%ebp)
80105948:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010594c:	7e 1c                	jle    8010596a <safestrcpy+0x3c>
8010594e:	8b 45 08             	mov    0x8(%ebp),%eax
80105951:	8d 50 01             	lea    0x1(%eax),%edx
80105954:	89 55 08             	mov    %edx,0x8(%ebp)
80105957:	8b 55 0c             	mov    0xc(%ebp),%edx
8010595a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010595d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105960:	8a 12                	mov    (%edx),%dl
80105962:	88 10                	mov    %dl,(%eax)
80105964:	8a 00                	mov    (%eax),%al
80105966:	84 c0                	test   %al,%al
80105968:	75 db                	jne    80105945 <safestrcpy+0x17>
    ;
  *s = 0;
8010596a:	8b 45 08             	mov    0x8(%ebp),%eax
8010596d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105970:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105973:	c9                   	leave  
80105974:	c3                   	ret    

80105975 <strlen>:

int
strlen(const char *s)
{
80105975:	55                   	push   %ebp
80105976:	89 e5                	mov    %esp,%ebp
80105978:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010597b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105982:	eb 03                	jmp    80105987 <strlen+0x12>
80105984:	ff 45 fc             	incl   -0x4(%ebp)
80105987:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010598a:	8b 45 08             	mov    0x8(%ebp),%eax
8010598d:	01 d0                	add    %edx,%eax
8010598f:	8a 00                	mov    (%eax),%al
80105991:	84 c0                	test   %al,%al
80105993:	75 ef                	jne    80105984 <strlen+0xf>
    ;
  return n;
80105995:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105998:	c9                   	leave  
80105999:	c3                   	ret    
	...

8010599c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010599c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801059a0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801059a4:	55                   	push   %ebp
  pushl %ebx
801059a5:	53                   	push   %ebx
  pushl %esi
801059a6:	56                   	push   %esi
  pushl %edi
801059a7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801059a8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801059aa:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801059ac:	5f                   	pop    %edi
  popl %esi
801059ad:	5e                   	pop    %esi
  popl %ebx
801059ae:	5b                   	pop    %ebx
  popl %ebp
801059af:	5d                   	pop    %ebp
  ret
801059b0:	c3                   	ret    
801059b1:	00 00                	add    %al,(%eax)
	...

801059b4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801059b4:	55                   	push   %ebp
801059b5:	89 e5                	mov    %esp,%ebp
801059b7:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801059ba:	e8 20 eb ff ff       	call   801044df <myproc>
801059bf:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801059c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c5:	8b 00                	mov    (%eax),%eax
801059c7:	3b 45 08             	cmp    0x8(%ebp),%eax
801059ca:	76 0f                	jbe    801059db <fetchint+0x27>
801059cc:	8b 45 08             	mov    0x8(%ebp),%eax
801059cf:	8d 50 04             	lea    0x4(%eax),%edx
801059d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d5:	8b 00                	mov    (%eax),%eax
801059d7:	39 c2                	cmp    %eax,%edx
801059d9:	76 07                	jbe    801059e2 <fetchint+0x2e>
    return -1;
801059db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e0:	eb 0f                	jmp    801059f1 <fetchint+0x3d>
  *ip = *(int*)(addr);
801059e2:	8b 45 08             	mov    0x8(%ebp),%eax
801059e5:	8b 10                	mov    (%eax),%edx
801059e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801059ea:	89 10                	mov    %edx,(%eax)
  return 0;
801059ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059f1:	c9                   	leave  
801059f2:	c3                   	ret    

801059f3 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801059f3:	55                   	push   %ebp
801059f4:	89 e5                	mov    %esp,%ebp
801059f6:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801059f9:	e8 e1 ea ff ff       	call   801044df <myproc>
801059fe:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a04:	8b 00                	mov    (%eax),%eax
80105a06:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a09:	77 07                	ja     80105a12 <fetchstr+0x1f>
    return -1;
80105a0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a10:	eb 41                	jmp    80105a53 <fetchstr+0x60>
  *pp = (char*)addr;
80105a12:	8b 55 08             	mov    0x8(%ebp),%edx
80105a15:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a18:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1d:	8b 00                	mov    (%eax),%eax
80105a1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a25:	8b 00                	mov    (%eax),%eax
80105a27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a2a:	eb 1a                	jmp    80105a46 <fetchstr+0x53>
    if(*s == 0)
80105a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2f:	8a 00                	mov    (%eax),%al
80105a31:	84 c0                	test   %al,%al
80105a33:	75 0e                	jne    80105a43 <fetchstr+0x50>
      return s - *pp;
80105a35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a38:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a3b:	8b 00                	mov    (%eax),%eax
80105a3d:	29 c2                	sub    %eax,%edx
80105a3f:	89 d0                	mov    %edx,%eax
80105a41:	eb 10                	jmp    80105a53 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105a43:	ff 45 f4             	incl   -0xc(%ebp)
80105a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a49:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105a4c:	72 de                	jb     80105a2c <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105a4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a53:	c9                   	leave  
80105a54:	c3                   	ret    

80105a55 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105a55:	55                   	push   %ebp
80105a56:	89 e5                	mov    %esp,%ebp
80105a58:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105a5b:	e8 7f ea ff ff       	call   801044df <myproc>
80105a60:	8b 40 18             	mov    0x18(%eax),%eax
80105a63:	8b 50 44             	mov    0x44(%eax),%edx
80105a66:	8b 45 08             	mov    0x8(%ebp),%eax
80105a69:	c1 e0 02             	shl    $0x2,%eax
80105a6c:	01 d0                	add    %edx,%eax
80105a6e:	8d 50 04             	lea    0x4(%eax),%edx
80105a71:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a74:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a78:	89 14 24             	mov    %edx,(%esp)
80105a7b:	e8 34 ff ff ff       	call   801059b4 <fetchint>
}
80105a80:	c9                   	leave  
80105a81:	c3                   	ret    

80105a82 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105a82:	55                   	push   %ebp
80105a83:	89 e5                	mov    %esp,%ebp
80105a85:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105a88:	e8 52 ea ff ff       	call   801044df <myproc>
80105a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105a90:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a93:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a97:	8b 45 08             	mov    0x8(%ebp),%eax
80105a9a:	89 04 24             	mov    %eax,(%esp)
80105a9d:	e8 b3 ff ff ff       	call   80105a55 <argint>
80105aa2:	85 c0                	test   %eax,%eax
80105aa4:	79 07                	jns    80105aad <argptr+0x2b>
    return -1;
80105aa6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aab:	eb 3d                	jmp    80105aea <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105aad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ab1:	78 21                	js     80105ad4 <argptr+0x52>
80105ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab6:	89 c2                	mov    %eax,%edx
80105ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abb:	8b 00                	mov    (%eax),%eax
80105abd:	39 c2                	cmp    %eax,%edx
80105abf:	73 13                	jae    80105ad4 <argptr+0x52>
80105ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac4:	89 c2                	mov    %eax,%edx
80105ac6:	8b 45 10             	mov    0x10(%ebp),%eax
80105ac9:	01 c2                	add    %eax,%edx
80105acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ace:	8b 00                	mov    (%eax),%eax
80105ad0:	39 c2                	cmp    %eax,%edx
80105ad2:	76 07                	jbe    80105adb <argptr+0x59>
    return -1;
80105ad4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad9:	eb 0f                	jmp    80105aea <argptr+0x68>
  *pp = (char*)i;
80105adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ade:	89 c2                	mov    %eax,%edx
80105ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ae3:	89 10                	mov    %edx,(%eax)
  return 0;
80105ae5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aea:	c9                   	leave  
80105aeb:	c3                   	ret    

80105aec <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105aec:	55                   	push   %ebp
80105aed:	89 e5                	mov    %esp,%ebp
80105aef:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105af2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105af5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af9:	8b 45 08             	mov    0x8(%ebp),%eax
80105afc:	89 04 24             	mov    %eax,(%esp)
80105aff:	e8 51 ff ff ff       	call   80105a55 <argint>
80105b04:	85 c0                	test   %eax,%eax
80105b06:	79 07                	jns    80105b0f <argstr+0x23>
    return -1;
80105b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0d:	eb 12                	jmp    80105b21 <argstr+0x35>
  return fetchstr(addr, pp);
80105b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b12:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b15:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b19:	89 04 24             	mov    %eax,(%esp)
80105b1c:	e8 d2 fe ff ff       	call   801059f3 <fetchstr>
}
80105b21:	c9                   	leave  
80105b22:	c3                   	ret    

80105b23 <syscall>:
[SYS_resume] sys_resume,
};

void
syscall(void)
{
80105b23:	55                   	push   %ebp
80105b24:	89 e5                	mov    %esp,%ebp
80105b26:	53                   	push   %ebx
80105b27:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105b2a:	e8 b0 e9 ff ff       	call   801044df <myproc>
80105b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b35:	8b 40 18             	mov    0x18(%eax),%eax
80105b38:	8b 40 1c             	mov    0x1c(%eax),%eax
80105b3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105b3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b42:	7e 2d                	jle    80105b71 <syscall+0x4e>
80105b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b47:	83 f8 31             	cmp    $0x31,%eax
80105b4a:	77 25                	ja     80105b71 <syscall+0x4e>
80105b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4f:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105b56:	85 c0                	test   %eax,%eax
80105b58:	74 17                	je     80105b71 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5d:	8b 58 18             	mov    0x18(%eax),%ebx
80105b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b63:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105b6a:	ff d0                	call   *%eax
80105b6c:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105b6f:	eb 34                	jmp    80105ba5 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b74:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7a:	8b 40 10             	mov    0x10(%eax),%eax
80105b7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b80:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105b84:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b88:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b8c:	c7 04 24 c3 9d 10 80 	movl   $0x80109dc3,(%esp)
80105b93:	e8 29 a8 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9b:	8b 40 18             	mov    0x18(%eax),%eax
80105b9e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105ba5:	83 c4 24             	add    $0x24,%esp
80105ba8:	5b                   	pop    %ebx
80105ba9:	5d                   	pop    %ebp
80105baa:	c3                   	ret    
	...

80105bac <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105bac:	55                   	push   %ebp
80105bad:	89 e5                	mov    %esp,%ebp
80105baf:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105bb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80105bbc:	89 04 24             	mov    %eax,(%esp)
80105bbf:	e8 91 fe ff ff       	call   80105a55 <argint>
80105bc4:	85 c0                	test   %eax,%eax
80105bc6:	79 07                	jns    80105bcf <argfd+0x23>
    return -1;
80105bc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bcd:	eb 4f                	jmp    80105c1e <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd2:	85 c0                	test   %eax,%eax
80105bd4:	78 20                	js     80105bf6 <argfd+0x4a>
80105bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd9:	83 f8 0f             	cmp    $0xf,%eax
80105bdc:	7f 18                	jg     80105bf6 <argfd+0x4a>
80105bde:	e8 fc e8 ff ff       	call   801044df <myproc>
80105be3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105be6:	83 c2 08             	add    $0x8,%edx
80105be9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105bed:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bf0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bf4:	75 07                	jne    80105bfd <argfd+0x51>
    return -1;
80105bf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfb:	eb 21                	jmp    80105c1e <argfd+0x72>
  if(pfd)
80105bfd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105c01:	74 08                	je     80105c0b <argfd+0x5f>
    *pfd = fd;
80105c03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c06:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c09:	89 10                	mov    %edx,(%eax)
  if(pf)
80105c0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c0f:	74 08                	je     80105c19 <argfd+0x6d>
    *pf = f;
80105c11:	8b 45 10             	mov    0x10(%ebp),%eax
80105c14:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c17:	89 10                	mov    %edx,(%eax)
  return 0;
80105c19:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c1e:	c9                   	leave  
80105c1f:	c3                   	ret    

80105c20 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105c20:	55                   	push   %ebp
80105c21:	89 e5                	mov    %esp,%ebp
80105c23:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105c26:	e8 b4 e8 ff ff       	call   801044df <myproc>
80105c2b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105c2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105c35:	eb 29                	jmp    80105c60 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c3d:	83 c2 08             	add    $0x8,%edx
80105c40:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c44:	85 c0                	test   %eax,%eax
80105c46:	75 15                	jne    80105c5d <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c4e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105c51:	8b 55 08             	mov    0x8(%ebp),%edx
80105c54:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5b:	eb 0e                	jmp    80105c6b <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105c5d:	ff 45 f4             	incl   -0xc(%ebp)
80105c60:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105c64:	7e d1                	jle    80105c37 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105c66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c6b:	c9                   	leave  
80105c6c:	c3                   	ret    

80105c6d <sys_dup>:

int
sys_dup(void)
{
80105c6d:	55                   	push   %ebp
80105c6e:	89 e5                	mov    %esp,%ebp
80105c70:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105c73:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c76:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c81:	00 
80105c82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c89:	e8 1e ff ff ff       	call   80105bac <argfd>
80105c8e:	85 c0                	test   %eax,%eax
80105c90:	79 07                	jns    80105c99 <sys_dup+0x2c>
    return -1;
80105c92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c97:	eb 29                	jmp    80105cc2 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9c:	89 04 24             	mov    %eax,(%esp)
80105c9f:	e8 7c ff ff ff       	call   80105c20 <fdalloc>
80105ca4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ca7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cab:	79 07                	jns    80105cb4 <sys_dup+0x47>
    return -1;
80105cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb2:	eb 0e                	jmp    80105cc2 <sys_dup+0x55>
  filedup(f);
80105cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb7:	89 04 24             	mov    %eax,(%esp)
80105cba:	e8 a3 b4 ff ff       	call   80101162 <filedup>
  return fd;
80105cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105cc2:	c9                   	leave  
80105cc3:	c3                   	ret    

80105cc4 <sys_read>:

int
sys_read(void)
{
80105cc4:	55                   	push   %ebp
80105cc5:	89 e5                	mov    %esp,%ebp
80105cc7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105cca:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ccd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cd8:	00 
80105cd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ce0:	e8 c7 fe ff ff       	call   80105bac <argfd>
80105ce5:	85 c0                	test   %eax,%eax
80105ce7:	78 35                	js     80105d1e <sys_read+0x5a>
80105ce9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cec:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cf0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105cf7:	e8 59 fd ff ff       	call   80105a55 <argint>
80105cfc:	85 c0                	test   %eax,%eax
80105cfe:	78 1e                	js     80105d1e <sys_read+0x5a>
80105d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d03:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d07:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d15:	e8 68 fd ff ff       	call   80105a82 <argptr>
80105d1a:	85 c0                	test   %eax,%eax
80105d1c:	79 07                	jns    80105d25 <sys_read+0x61>
    return -1;
80105d1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d23:	eb 19                	jmp    80105d3e <sys_read+0x7a>
  return fileread(f, p, n);
80105d25:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d28:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d32:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d36:	89 04 24             	mov    %eax,(%esp)
80105d39:	e8 85 b5 ff ff       	call   801012c3 <fileread>
}
80105d3e:	c9                   	leave  
80105d3f:	c3                   	ret    

80105d40 <sys_write>:

int
sys_write(void)
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
80105d5c:	e8 4b fe ff ff       	call   80105bac <argfd>
80105d61:	85 c0                	test   %eax,%eax
80105d63:	78 35                	js     80105d9a <sys_write+0x5a>
80105d65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d68:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d6c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105d73:	e8 dd fc ff ff       	call   80105a55 <argint>
80105d78:	85 c0                	test   %eax,%eax
80105d7a:	78 1e                	js     80105d9a <sys_write+0x5a>
80105d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d83:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d86:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d91:	e8 ec fc ff ff       	call   80105a82 <argptr>
80105d96:	85 c0                	test   %eax,%eax
80105d98:	79 07                	jns    80105da1 <sys_write+0x61>
    return -1;
80105d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9f:	eb 19                	jmp    80105dba <sys_write+0x7a>
  return filewrite(f, p, n);
80105da1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105da4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105dae:	89 54 24 04          	mov    %edx,0x4(%esp)
80105db2:	89 04 24             	mov    %eax,(%esp)
80105db5:	e8 c4 b5 ff ff       	call   8010137e <filewrite>
}
80105dba:	c9                   	leave  
80105dbb:	c3                   	ret    

80105dbc <sys_close>:

int
sys_close(void)
{
80105dbc:	55                   	push   %ebp
80105dbd:	89 e5                	mov    %esp,%ebp
80105dbf:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105dc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dc5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dd7:	e8 d0 fd ff ff       	call   80105bac <argfd>
80105ddc:	85 c0                	test   %eax,%eax
80105dde:	79 07                	jns    80105de7 <sys_close+0x2b>
    return -1;
80105de0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de5:	eb 23                	jmp    80105e0a <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105de7:	e8 f3 e6 ff ff       	call   801044df <myproc>
80105dec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105def:	83 c2 08             	add    $0x8,%edx
80105df2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105df9:	00 
  fileclose(f);
80105dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dfd:	89 04 24             	mov    %eax,(%esp)
80105e00:	e8 a5 b3 ff ff       	call   801011aa <fileclose>
  return 0;
80105e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e0a:	c9                   	leave  
80105e0b:	c3                   	ret    

80105e0c <sys_fstat>:

int
sys_fstat(void)
{
80105e0c:	55                   	push   %ebp
80105e0d:	89 e5                	mov    %esp,%ebp
80105e0f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105e12:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e15:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e20:	00 
80105e21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e28:	e8 7f fd ff ff       	call   80105bac <argfd>
80105e2d:	85 c0                	test   %eax,%eax
80105e2f:	78 1f                	js     80105e50 <sys_fstat+0x44>
80105e31:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105e38:	00 
80105e39:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e47:	e8 36 fc ff ff       	call   80105a82 <argptr>
80105e4c:	85 c0                	test   %eax,%eax
80105e4e:	79 07                	jns    80105e57 <sys_fstat+0x4b>
    return -1;
80105e50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e55:	eb 12                	jmp    80105e69 <sys_fstat+0x5d>
  return filestat(f, st);
80105e57:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e61:	89 04 24             	mov    %eax,(%esp)
80105e64:	e8 0b b4 ff ff       	call   80101274 <filestat>
}
80105e69:	c9                   	leave  
80105e6a:	c3                   	ret    

80105e6b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105e6b:	55                   	push   %ebp
80105e6c:	89 e5                	mov    %esp,%ebp
80105e6e:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105e71:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105e74:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e7f:	e8 68 fc ff ff       	call   80105aec <argstr>
80105e84:	85 c0                	test   %eax,%eax
80105e86:	78 17                	js     80105e9f <sys_link+0x34>
80105e88:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e8f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e96:	e8 51 fc ff ff       	call   80105aec <argstr>
80105e9b:	85 c0                	test   %eax,%eax
80105e9d:	79 0a                	jns    80105ea9 <sys_link+0x3e>
    return -1;
80105e9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea4:	e9 3d 01 00 00       	jmp    80105fe6 <sys_link+0x17b>

  begin_op();
80105ea9:	e8 31 d9 ff ff       	call   801037df <begin_op>
  if((ip = namei(old)) == 0){
80105eae:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105eb1:	89 04 24             	mov    %eax,(%esp)
80105eb4:	e8 9f c8 ff ff       	call   80102758 <namei>
80105eb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ebc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ec0:	75 0f                	jne    80105ed1 <sys_link+0x66>
    end_op();
80105ec2:	e8 9a d9 ff ff       	call   80103861 <end_op>
    return -1;
80105ec7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ecc:	e9 15 01 00 00       	jmp    80105fe6 <sys_link+0x17b>
  }

  ilock(ip);
80105ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed4:	89 04 24             	mov    %eax,(%esp)
80105ed7:	e8 e6 bb ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edf:	8b 40 50             	mov    0x50(%eax),%eax
80105ee2:	66 83 f8 01          	cmp    $0x1,%ax
80105ee6:	75 1a                	jne    80105f02 <sys_link+0x97>
    iunlockput(ip);
80105ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eeb:	89 04 24             	mov    %eax,(%esp)
80105eee:	e8 ce bd ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105ef3:	e8 69 d9 ff ff       	call   80103861 <end_op>
    return -1;
80105ef8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105efd:	e9 e4 00 00 00       	jmp    80105fe6 <sys_link+0x17b>
  }

  ip->nlink++;
80105f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f05:	66 8b 40 56          	mov    0x56(%eax),%ax
80105f09:	40                   	inc    %eax
80105f0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f0d:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f14:	89 04 24             	mov    %eax,(%esp)
80105f17:	e8 e3 b9 ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1f:	89 04 24             	mov    %eax,(%esp)
80105f22:	e8 a5 bc ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105f27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105f2a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105f2d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f31:	89 04 24             	mov    %eax,(%esp)
80105f34:	e8 41 c8 ff ff       	call   8010277a <nameiparent>
80105f39:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f40:	75 02                	jne    80105f44 <sys_link+0xd9>
    goto bad;
80105f42:	eb 68                	jmp    80105fac <sys_link+0x141>
  ilock(dp);
80105f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f47:	89 04 24             	mov    %eax,(%esp)
80105f4a:	e8 73 bb ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f52:	8b 10                	mov    (%eax),%edx
80105f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f57:	8b 00                	mov    (%eax),%eax
80105f59:	39 c2                	cmp    %eax,%edx
80105f5b:	75 20                	jne    80105f7d <sys_link+0x112>
80105f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f60:	8b 40 04             	mov    0x4(%eax),%eax
80105f63:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f67:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105f6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f71:	89 04 24             	mov    %eax,(%esp)
80105f74:	e8 24 c4 ff ff       	call   8010239d <dirlink>
80105f79:	85 c0                	test   %eax,%eax
80105f7b:	79 0d                	jns    80105f8a <sys_link+0x11f>
    iunlockput(dp);
80105f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f80:	89 04 24             	mov    %eax,(%esp)
80105f83:	e8 39 bd ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105f88:	eb 22                	jmp    80105fac <sys_link+0x141>
  }
  iunlockput(dp);
80105f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8d:	89 04 24             	mov    %eax,(%esp)
80105f90:	e8 2c bd ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
80105f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f98:	89 04 24             	mov    %eax,(%esp)
80105f9b:	e8 70 bc ff ff       	call   80101c10 <iput>

  end_op();
80105fa0:	e8 bc d8 ff ff       	call   80103861 <end_op>

  return 0;
80105fa5:	b8 00 00 00 00       	mov    $0x0,%eax
80105faa:	eb 3a                	jmp    80105fe6 <sys_link+0x17b>

bad:
  ilock(ip);
80105fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105faf:	89 04 24             	mov    %eax,(%esp)
80105fb2:	e8 0b bb ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
80105fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fba:	66 8b 40 56          	mov    0x56(%eax),%ax
80105fbe:	48                   	dec    %eax
80105fbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fc2:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc9:	89 04 24             	mov    %eax,(%esp)
80105fcc:	e8 2e b9 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd4:	89 04 24             	mov    %eax,(%esp)
80105fd7:	e8 e5 bc ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105fdc:	e8 80 d8 ff ff       	call   80103861 <end_op>
  return -1;
80105fe1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fe6:	c9                   	leave  
80105fe7:	c3                   	ret    

80105fe8 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105fe8:	55                   	push   %ebp
80105fe9:	89 e5                	mov    %esp,%ebp
80105feb:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105fee:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ff5:	eb 4a                	jmp    80106041 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffa:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106001:	00 
80106002:	89 44 24 08          	mov    %eax,0x8(%esp)
80106006:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106009:	89 44 24 04          	mov    %eax,0x4(%esp)
8010600d:	8b 45 08             	mov    0x8(%ebp),%eax
80106010:	89 04 24             	mov    %eax,(%esp)
80106013:	e8 41 bf ff ff       	call   80101f59 <readi>
80106018:	83 f8 10             	cmp    $0x10,%eax
8010601b:	74 0c                	je     80106029 <isdirempty+0x41>
      panic("isdirempty: readi");
8010601d:	c7 04 24 df 9d 10 80 	movl   $0x80109ddf,(%esp)
80106024:	e8 2b a5 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80106029:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010602c:	66 85 c0             	test   %ax,%ax
8010602f:	74 07                	je     80106038 <isdirempty+0x50>
      return 0;
80106031:	b8 00 00 00 00       	mov    $0x0,%eax
80106036:	eb 1b                	jmp    80106053 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603b:	83 c0 10             	add    $0x10,%eax
8010603e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106041:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106044:	8b 45 08             	mov    0x8(%ebp),%eax
80106047:	8b 40 58             	mov    0x58(%eax),%eax
8010604a:	39 c2                	cmp    %eax,%edx
8010604c:	72 a9                	jb     80105ff7 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010604e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106053:	c9                   	leave  
80106054:	c3                   	ret    

80106055 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106055:	55                   	push   %ebp
80106056:	89 e5                	mov    %esp,%ebp
80106058:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010605b:	8d 45 bc             	lea    -0x44(%ebp),%eax
8010605e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106069:	e8 7e fa ff ff       	call   80105aec <argstr>
8010606e:	85 c0                	test   %eax,%eax
80106070:	79 0a                	jns    8010607c <sys_unlink+0x27>
    return -1;
80106072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106077:	e9 f1 01 00 00       	jmp    8010626d <sys_unlink+0x218>

  begin_op();
8010607c:	e8 5e d7 ff ff       	call   801037df <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106081:	8b 45 bc             	mov    -0x44(%ebp),%eax
80106084:	8d 55 c2             	lea    -0x3e(%ebp),%edx
80106087:	89 54 24 04          	mov    %edx,0x4(%esp)
8010608b:	89 04 24             	mov    %eax,(%esp)
8010608e:	e8 e7 c6 ff ff       	call   8010277a <nameiparent>
80106093:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106096:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010609a:	75 0f                	jne    801060ab <sys_unlink+0x56>
    end_op();
8010609c:	e8 c0 d7 ff ff       	call   80103861 <end_op>
    return -1;
801060a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a6:	e9 c2 01 00 00       	jmp    8010626d <sys_unlink+0x218>
  }

  ilock(dp);
801060ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ae:	89 04 24             	mov    %eax,(%esp)
801060b1:	e8 0c ba ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801060b6:	c7 44 24 04 f1 9d 10 	movl   $0x80109df1,0x4(%esp)
801060bd:	80 
801060be:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801060c1:	89 04 24             	mov    %eax,(%esp)
801060c4:	e8 ec c1 ff ff       	call   801022b5 <namecmp>
801060c9:	85 c0                	test   %eax,%eax
801060cb:	0f 84 87 01 00 00    	je     80106258 <sys_unlink+0x203>
801060d1:	c7 44 24 04 f3 9d 10 	movl   $0x80109df3,0x4(%esp)
801060d8:	80 
801060d9:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801060dc:	89 04 24             	mov    %eax,(%esp)
801060df:	e8 d1 c1 ff ff       	call   801022b5 <namecmp>
801060e4:	85 c0                	test   %eax,%eax
801060e6:	0f 84 6c 01 00 00    	je     80106258 <sys_unlink+0x203>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801060ec:	8d 45 b8             	lea    -0x48(%ebp),%eax
801060ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801060f3:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801060f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801060fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fd:	89 04 24             	mov    %eax,(%esp)
80106100:	e8 d2 c1 ff ff       	call   801022d7 <dirlookup>
80106105:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106108:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010610c:	75 05                	jne    80106113 <sys_unlink+0xbe>
    goto bad;
8010610e:	e9 45 01 00 00       	jmp    80106258 <sys_unlink+0x203>
  ilock(ip);
80106113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106116:	89 04 24             	mov    %eax,(%esp)
80106119:	e8 a4 b9 ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
8010611e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106121:	66 8b 40 56          	mov    0x56(%eax),%ax
80106125:	66 85 c0             	test   %ax,%ax
80106128:	7f 0c                	jg     80106136 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
8010612a:	c7 04 24 f6 9d 10 80 	movl   $0x80109df6,(%esp)
80106131:	e8 1e a4 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106139:	8b 40 50             	mov    0x50(%eax),%eax
8010613c:	66 83 f8 01          	cmp    $0x1,%ax
80106140:	75 1f                	jne    80106161 <sys_unlink+0x10c>
80106142:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106145:	89 04 24             	mov    %eax,(%esp)
80106148:	e8 9b fe ff ff       	call   80105fe8 <isdirempty>
8010614d:	85 c0                	test   %eax,%eax
8010614f:	75 10                	jne    80106161 <sys_unlink+0x10c>
    iunlockput(ip);
80106151:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106154:	89 04 24             	mov    %eax,(%esp)
80106157:	e8 65 bb ff ff       	call   80101cc1 <iunlockput>
    goto bad;
8010615c:	e9 f7 00 00 00       	jmp    80106258 <sys_unlink+0x203>
  }

  memset(&de, 0, sizeof(de));
80106161:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106168:	00 
80106169:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106170:	00 
80106171:	8d 45 d0             	lea    -0x30(%ebp),%eax
80106174:	89 04 24             	mov    %eax,(%esp)
80106177:	e8 a6 f5 ff ff       	call   80105722 <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
8010617c:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010617f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106186:	00 
80106187:	89 44 24 08          	mov    %eax,0x8(%esp)
8010618b:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010618e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106195:	89 04 24             	mov    %eax,(%esp)
80106198:	e8 20 bf ff ff       	call   801020bd <writei>
8010619d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
801061a0:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
801061a4:	74 0c                	je     801061b2 <sys_unlink+0x15d>
    panic("unlink: writei");
801061a6:	c7 04 24 08 9e 10 80 	movl   $0x80109e08,(%esp)
801061ad:	e8 a2 a3 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
801061b2:	e8 28 e3 ff ff       	call   801044df <myproc>
801061b7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801061bd:	83 c0 18             	add    $0x18,%eax
801061c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
801061c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061c6:	89 04 24             	mov    %eax,(%esp)
801061c9:	e8 9d 2f 00 00       	call   8010916b <find>
801061ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int set = z/2;
801061d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061d4:	89 c2                	mov    %eax,%edx
801061d6:	c1 ea 1f             	shr    $0x1f,%edx
801061d9:	01 d0                	add    %edx,%eax
801061db:	d1 f8                	sar    %eax
801061dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_curr_disk(-set, x);
801061e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801061e3:	f7 d8                	neg    %eax
801061e5:	89 c2                	mov    %eax,%edx
801061e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ee:	89 14 24             	mov    %edx,(%esp)
801061f1:	e8 0a 33 00 00       	call   80109500 <set_curr_disk>
  if(ip->type == T_DIR){
801061f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f9:	8b 40 50             	mov    0x50(%eax),%eax
801061fc:	66 83 f8 01          	cmp    $0x1,%ax
80106200:	75 1a                	jne    8010621c <sys_unlink+0x1c7>
    dp->nlink--;
80106202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106205:	66 8b 40 56          	mov    0x56(%eax),%ax
80106209:	48                   	dec    %eax
8010620a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010620d:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106214:	89 04 24             	mov    %eax,(%esp)
80106217:	e8 e3 b6 ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
8010621c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621f:	89 04 24             	mov    %eax,(%esp)
80106222:	e8 9a ba ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
80106227:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622a:	66 8b 40 56          	mov    0x56(%eax),%ax
8010622e:	48                   	dec    %eax
8010622f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106232:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106236:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106239:	89 04 24             	mov    %eax,(%esp)
8010623c:	e8 be b6 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80106241:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106244:	89 04 24             	mov    %eax,(%esp)
80106247:	e8 75 ba ff ff       	call   80101cc1 <iunlockput>

  end_op();
8010624c:	e8 10 d6 ff ff       	call   80103861 <end_op>

  return 0;
80106251:	b8 00 00 00 00       	mov    $0x0,%eax
80106256:	eb 15                	jmp    8010626d <sys_unlink+0x218>

bad:
  iunlockput(dp);
80106258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625b:	89 04 24             	mov    %eax,(%esp)
8010625e:	e8 5e ba ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106263:	e8 f9 d5 ff ff       	call   80103861 <end_op>
  return -1;
80106268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010626d:	c9                   	leave  
8010626e:	c3                   	ret    

8010626f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010626f:	55                   	push   %ebp
80106270:	89 e5                	mov    %esp,%ebp
80106272:	83 ec 48             	sub    $0x48,%esp
80106275:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106278:	8b 55 10             	mov    0x10(%ebp),%edx
8010627b:	8b 45 14             	mov    0x14(%ebp),%eax
8010627e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106282:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106286:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010628a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010628d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106291:	8b 45 08             	mov    0x8(%ebp),%eax
80106294:	89 04 24             	mov    %eax,(%esp)
80106297:	e8 de c4 ff ff       	call   8010277a <nameiparent>
8010629c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010629f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062a3:	75 0a                	jne    801062af <create+0x40>
    return 0;
801062a5:	b8 00 00 00 00       	mov    $0x0,%eax
801062aa:	e9 79 01 00 00       	jmp    80106428 <create+0x1b9>
  ilock(dp);
801062af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b2:	89 04 24             	mov    %eax,(%esp)
801062b5:	e8 08 b8 ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801062ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062bd:	89 44 24 08          	mov    %eax,0x8(%esp)
801062c1:	8d 45 de             	lea    -0x22(%ebp),%eax
801062c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cb:	89 04 24             	mov    %eax,(%esp)
801062ce:	e8 04 c0 ff ff       	call   801022d7 <dirlookup>
801062d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062da:	74 46                	je     80106322 <create+0xb3>
    iunlockput(dp);
801062dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062df:	89 04 24             	mov    %eax,(%esp)
801062e2:	e8 da b9 ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
801062e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ea:	89 04 24             	mov    %eax,(%esp)
801062ed:	e8 d0 b7 ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801062f2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801062f7:	75 14                	jne    8010630d <create+0x9e>
801062f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fc:	8b 40 50             	mov    0x50(%eax),%eax
801062ff:	66 83 f8 02          	cmp    $0x2,%ax
80106303:	75 08                	jne    8010630d <create+0x9e>
      return ip;
80106305:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106308:	e9 1b 01 00 00       	jmp    80106428 <create+0x1b9>
    iunlockput(ip);
8010630d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106310:	89 04 24             	mov    %eax,(%esp)
80106313:	e8 a9 b9 ff ff       	call   80101cc1 <iunlockput>
    return 0;
80106318:	b8 00 00 00 00       	mov    $0x0,%eax
8010631d:	e9 06 01 00 00       	jmp    80106428 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106322:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106329:	8b 00                	mov    (%eax),%eax
8010632b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010632f:	89 04 24             	mov    %eax,(%esp)
80106332:	e8 f6 b4 ff ff       	call   8010182d <ialloc>
80106337:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010633a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010633e:	75 0c                	jne    8010634c <create+0xdd>
    panic("create: ialloc");
80106340:	c7 04 24 17 9e 10 80 	movl   $0x80109e17,(%esp)
80106347:	e8 08 a2 ff ff       	call   80100554 <panic>

  ilock(ip);
8010634c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634f:	89 04 24             	mov    %eax,(%esp)
80106352:	e8 6b b7 ff ff       	call   80101ac2 <ilock>
  ip->major = major;
80106357:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010635a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010635d:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106361:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106364:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106367:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
8010636b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010636e:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106377:	89 04 24             	mov    %eax,(%esp)
8010637a:	e8 80 b5 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010637f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106384:	75 68                	jne    801063ee <create+0x17f>
    dp->nlink++;  // for ".."
80106386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106389:	66 8b 40 56          	mov    0x56(%eax),%ax
8010638d:	40                   	inc    %eax
8010638e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106391:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106398:	89 04 24             	mov    %eax,(%esp)
8010639b:	e8 5f b5 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801063a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a3:	8b 40 04             	mov    0x4(%eax),%eax
801063a6:	89 44 24 08          	mov    %eax,0x8(%esp)
801063aa:	c7 44 24 04 f1 9d 10 	movl   $0x80109df1,0x4(%esp)
801063b1:	80 
801063b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b5:	89 04 24             	mov    %eax,(%esp)
801063b8:	e8 e0 bf ff ff       	call   8010239d <dirlink>
801063bd:	85 c0                	test   %eax,%eax
801063bf:	78 21                	js     801063e2 <create+0x173>
801063c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c4:	8b 40 04             	mov    0x4(%eax),%eax
801063c7:	89 44 24 08          	mov    %eax,0x8(%esp)
801063cb:	c7 44 24 04 f3 9d 10 	movl   $0x80109df3,0x4(%esp)
801063d2:	80 
801063d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d6:	89 04 24             	mov    %eax,(%esp)
801063d9:	e8 bf bf ff ff       	call   8010239d <dirlink>
801063de:	85 c0                	test   %eax,%eax
801063e0:	79 0c                	jns    801063ee <create+0x17f>
      panic("create dots");
801063e2:	c7 04 24 26 9e 10 80 	movl   $0x80109e26,(%esp)
801063e9:	e8 66 a1 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801063ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f1:	8b 40 04             	mov    0x4(%eax),%eax
801063f4:	89 44 24 08          	mov    %eax,0x8(%esp)
801063f8:	8d 45 de             	lea    -0x22(%ebp),%eax
801063fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801063ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106402:	89 04 24             	mov    %eax,(%esp)
80106405:	e8 93 bf ff ff       	call   8010239d <dirlink>
8010640a:	85 c0                	test   %eax,%eax
8010640c:	79 0c                	jns    8010641a <create+0x1ab>
    panic("create: dirlink");
8010640e:	c7 04 24 32 9e 10 80 	movl   $0x80109e32,(%esp)
80106415:	e8 3a a1 ff ff       	call   80100554 <panic>

  iunlockput(dp);
8010641a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010641d:	89 04 24             	mov    %eax,(%esp)
80106420:	e8 9c b8 ff ff       	call   80101cc1 <iunlockput>

  return ip;
80106425:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106428:	c9                   	leave  
80106429:	c3                   	ret    

8010642a <sys_open>:

int
sys_open(void)
{
8010642a:	55                   	push   %ebp
8010642b:	89 e5                	mov    %esp,%ebp
8010642d:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106430:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106433:	89 44 24 04          	mov    %eax,0x4(%esp)
80106437:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010643e:	e8 a9 f6 ff ff       	call   80105aec <argstr>
80106443:	85 c0                	test   %eax,%eax
80106445:	78 17                	js     8010645e <sys_open+0x34>
80106447:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010644a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010644e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106455:	e8 fb f5 ff ff       	call   80105a55 <argint>
8010645a:	85 c0                	test   %eax,%eax
8010645c:	79 0a                	jns    80106468 <sys_open+0x3e>
    return -1;
8010645e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106463:	e9 64 01 00 00       	jmp    801065cc <sys_open+0x1a2>

  begin_op();
80106468:	e8 72 d3 ff ff       	call   801037df <begin_op>

  if(omode & O_CREATE){
8010646d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106470:	25 00 02 00 00       	and    $0x200,%eax
80106475:	85 c0                	test   %eax,%eax
80106477:	74 3b                	je     801064b4 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106479:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010647c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106483:	00 
80106484:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010648b:	00 
8010648c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106493:	00 
80106494:	89 04 24             	mov    %eax,(%esp)
80106497:	e8 d3 fd ff ff       	call   8010626f <create>
8010649c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010649f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064a3:	75 6a                	jne    8010650f <sys_open+0xe5>
      end_op();
801064a5:	e8 b7 d3 ff ff       	call   80103861 <end_op>
      return -1;
801064aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064af:	e9 18 01 00 00       	jmp    801065cc <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
801064b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064b7:	89 04 24             	mov    %eax,(%esp)
801064ba:	e8 99 c2 ff ff       	call   80102758 <namei>
801064bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064c6:	75 0f                	jne    801064d7 <sys_open+0xad>
      end_op();
801064c8:	e8 94 d3 ff ff       	call   80103861 <end_op>
      return -1;
801064cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d2:	e9 f5 00 00 00       	jmp    801065cc <sys_open+0x1a2>
    }
    ilock(ip);
801064d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064da:	89 04 24             	mov    %eax,(%esp)
801064dd:	e8 e0 b5 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801064e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e5:	8b 40 50             	mov    0x50(%eax),%eax
801064e8:	66 83 f8 01          	cmp    $0x1,%ax
801064ec:	75 21                	jne    8010650f <sys_open+0xe5>
801064ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064f1:	85 c0                	test   %eax,%eax
801064f3:	74 1a                	je     8010650f <sys_open+0xe5>
      iunlockput(ip);
801064f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f8:	89 04 24             	mov    %eax,(%esp)
801064fb:	e8 c1 b7 ff ff       	call   80101cc1 <iunlockput>
      end_op();
80106500:	e8 5c d3 ff ff       	call   80103861 <end_op>
      return -1;
80106505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650a:	e9 bd 00 00 00       	jmp    801065cc <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010650f:	e8 ee ab ff ff       	call   80101102 <filealloc>
80106514:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106517:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010651b:	74 14                	je     80106531 <sys_open+0x107>
8010651d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106520:	89 04 24             	mov    %eax,(%esp)
80106523:	e8 f8 f6 ff ff       	call   80105c20 <fdalloc>
80106528:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010652b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010652f:	79 28                	jns    80106559 <sys_open+0x12f>
    if(f)
80106531:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106535:	74 0b                	je     80106542 <sys_open+0x118>
      fileclose(f);
80106537:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010653a:	89 04 24             	mov    %eax,(%esp)
8010653d:	e8 68 ac ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
80106542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106545:	89 04 24             	mov    %eax,(%esp)
80106548:	e8 74 b7 ff ff       	call   80101cc1 <iunlockput>
    end_op();
8010654d:	e8 0f d3 ff ff       	call   80103861 <end_op>
    return -1;
80106552:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106557:	eb 73                	jmp    801065cc <sys_open+0x1a2>
  }
  iunlock(ip);
80106559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010655c:	89 04 24             	mov    %eax,(%esp)
8010655f:	e8 68 b6 ff ff       	call   80101bcc <iunlock>
  end_op();
80106564:	e8 f8 d2 ff ff       	call   80103861 <end_op>

  f->type = FD_INODE;
80106569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010656c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106572:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106575:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106578:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010657b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010657e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106585:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106588:	83 e0 01             	and    $0x1,%eax
8010658b:	85 c0                	test   %eax,%eax
8010658d:	0f 94 c0             	sete   %al
80106590:	88 c2                	mov    %al,%dl
80106592:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106595:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010659b:	83 e0 01             	and    $0x1,%eax
8010659e:	85 c0                	test   %eax,%eax
801065a0:	75 0a                	jne    801065ac <sys_open+0x182>
801065a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065a5:	83 e0 02             	and    $0x2,%eax
801065a8:	85 c0                	test   %eax,%eax
801065aa:	74 07                	je     801065b3 <sys_open+0x189>
801065ac:	b8 01 00 00 00       	mov    $0x1,%eax
801065b1:	eb 05                	jmp    801065b8 <sys_open+0x18e>
801065b3:	b8 00 00 00 00       	mov    $0x0,%eax
801065b8:	88 c2                	mov    %al,%dl
801065ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065bd:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
801065c0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801065c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c6:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
801065c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801065cc:	c9                   	leave  
801065cd:	c3                   	ret    

801065ce <sys_mkdir>:

int
sys_mkdir(void)
{
801065ce:	55                   	push   %ebp
801065cf:	89 e5                	mov    %esp,%ebp
801065d1:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801065d4:	e8 06 d2 ff ff       	call   801037df <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801065d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801065e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065e7:	e8 00 f5 ff ff       	call   80105aec <argstr>
801065ec:	85 c0                	test   %eax,%eax
801065ee:	78 2c                	js     8010661c <sys_mkdir+0x4e>
801065f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801065fa:	00 
801065fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106602:	00 
80106603:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010660a:	00 
8010660b:	89 04 24             	mov    %eax,(%esp)
8010660e:	e8 5c fc ff ff       	call   8010626f <create>
80106613:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106616:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010661a:	75 0c                	jne    80106628 <sys_mkdir+0x5a>
    end_op();
8010661c:	e8 40 d2 ff ff       	call   80103861 <end_op>
    return -1;
80106621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106626:	eb 15                	jmp    8010663d <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010662b:	89 04 24             	mov    %eax,(%esp)
8010662e:	e8 8e b6 ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106633:	e8 29 d2 ff ff       	call   80103861 <end_op>
  return 0;
80106638:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010663d:	c9                   	leave  
8010663e:	c3                   	ret    

8010663f <sys_mknod>:

int
sys_mknod(void)
{
8010663f:	55                   	push   %ebp
80106640:	89 e5                	mov    %esp,%ebp
80106642:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106645:	e8 95 d1 ff ff       	call   801037df <begin_op>
  if((argstr(0, &path)) < 0 ||
8010664a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010664d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106651:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106658:	e8 8f f4 ff ff       	call   80105aec <argstr>
8010665d:	85 c0                	test   %eax,%eax
8010665f:	78 5e                	js     801066bf <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106661:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106664:	89 44 24 04          	mov    %eax,0x4(%esp)
80106668:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010666f:	e8 e1 f3 ff ff       	call   80105a55 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106674:	85 c0                	test   %eax,%eax
80106676:	78 47                	js     801066bf <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106678:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010667b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010667f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106686:	e8 ca f3 ff ff       	call   80105a55 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010668b:	85 c0                	test   %eax,%eax
8010668d:	78 30                	js     801066bf <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010668f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106692:	0f bf c8             	movswl %ax,%ecx
80106695:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106698:	0f bf d0             	movswl %ax,%edx
8010669b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010669e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801066a2:	89 54 24 08          	mov    %edx,0x8(%esp)
801066a6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801066ad:	00 
801066ae:	89 04 24             	mov    %eax,(%esp)
801066b1:	e8 b9 fb ff ff       	call   8010626f <create>
801066b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066bd:	75 0c                	jne    801066cb <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801066bf:	e8 9d d1 ff ff       	call   80103861 <end_op>
    return -1;
801066c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c9:	eb 15                	jmp    801066e0 <sys_mknod+0xa1>
  }
  iunlockput(ip);
801066cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ce:	89 04 24             	mov    %eax,(%esp)
801066d1:	e8 eb b5 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801066d6:	e8 86 d1 ff ff       	call   80103861 <end_op>
  return 0;
801066db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066e0:	c9                   	leave  
801066e1:	c3                   	ret    

801066e2 <sys_chdir>:

int
sys_chdir(void)
{
801066e2:	55                   	push   %ebp
801066e3:	89 e5                	mov    %esp,%ebp
801066e5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801066e8:	e8 f2 dd ff ff       	call   801044df <myproc>
801066ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801066f0:	e8 ea d0 ff ff       	call   801037df <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801066f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801066fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106703:	e8 e4 f3 ff ff       	call   80105aec <argstr>
80106708:	85 c0                	test   %eax,%eax
8010670a:	78 14                	js     80106720 <sys_chdir+0x3e>
8010670c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010670f:	89 04 24             	mov    %eax,(%esp)
80106712:	e8 41 c0 ff ff       	call   80102758 <namei>
80106717:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010671a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010671e:	75 0c                	jne    8010672c <sys_chdir+0x4a>
    end_op();
80106720:	e8 3c d1 ff ff       	call   80103861 <end_op>
    return -1;
80106725:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010672a:	eb 5a                	jmp    80106786 <sys_chdir+0xa4>
  }
  ilock(ip);
8010672c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010672f:	89 04 24             	mov    %eax,(%esp)
80106732:	e8 8b b3 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
80106737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010673a:	8b 40 50             	mov    0x50(%eax),%eax
8010673d:	66 83 f8 01          	cmp    $0x1,%ax
80106741:	74 17                	je     8010675a <sys_chdir+0x78>
    iunlockput(ip);
80106743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106746:	89 04 24             	mov    %eax,(%esp)
80106749:	e8 73 b5 ff ff       	call   80101cc1 <iunlockput>
    end_op();
8010674e:	e8 0e d1 ff ff       	call   80103861 <end_op>
    return -1;
80106753:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106758:	eb 2c                	jmp    80106786 <sys_chdir+0xa4>
  }
  iunlock(ip);
8010675a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010675d:	89 04 24             	mov    %eax,(%esp)
80106760:	e8 67 b4 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
80106765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106768:	8b 40 68             	mov    0x68(%eax),%eax
8010676b:	89 04 24             	mov    %eax,(%esp)
8010676e:	e8 9d b4 ff ff       	call   80101c10 <iput>
  end_op();
80106773:	e8 e9 d0 ff ff       	call   80103861 <end_op>
  curproc->cwd = ip;
80106778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010677e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106781:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106786:	c9                   	leave  
80106787:	c3                   	ret    

80106788 <sys_exec>:

int
sys_exec(void)
{
80106788:	55                   	push   %ebp
80106789:	89 e5                	mov    %esp,%ebp
8010678b:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106791:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106794:	89 44 24 04          	mov    %eax,0x4(%esp)
80106798:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010679f:	e8 48 f3 ff ff       	call   80105aec <argstr>
801067a4:	85 c0                	test   %eax,%eax
801067a6:	78 1a                	js     801067c2 <sys_exec+0x3a>
801067a8:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801067ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801067b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801067b9:	e8 97 f2 ff ff       	call   80105a55 <argint>
801067be:	85 c0                	test   %eax,%eax
801067c0:	79 0a                	jns    801067cc <sys_exec+0x44>
    return -1;
801067c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c7:	e9 c7 00 00 00       	jmp    80106893 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
801067cc:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801067d3:	00 
801067d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801067db:	00 
801067dc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801067e2:	89 04 24             	mov    %eax,(%esp)
801067e5:	e8 38 ef ff ff       	call   80105722 <memset>
  for(i=0;; i++){
801067ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801067f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f4:	83 f8 1f             	cmp    $0x1f,%eax
801067f7:	76 0a                	jbe    80106803 <sys_exec+0x7b>
      return -1;
801067f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067fe:	e9 90 00 00 00       	jmp    80106893 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106806:	c1 e0 02             	shl    $0x2,%eax
80106809:	89 c2                	mov    %eax,%edx
8010680b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106811:	01 c2                	add    %eax,%edx
80106813:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106819:	89 44 24 04          	mov    %eax,0x4(%esp)
8010681d:	89 14 24             	mov    %edx,(%esp)
80106820:	e8 8f f1 ff ff       	call   801059b4 <fetchint>
80106825:	85 c0                	test   %eax,%eax
80106827:	79 07                	jns    80106830 <sys_exec+0xa8>
      return -1;
80106829:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010682e:	eb 63                	jmp    80106893 <sys_exec+0x10b>
    if(uarg == 0){
80106830:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106836:	85 c0                	test   %eax,%eax
80106838:	75 26                	jne    80106860 <sys_exec+0xd8>
      argv[i] = 0;
8010683a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106844:	00 00 00 00 
      break;
80106848:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106849:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010684c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106852:	89 54 24 04          	mov    %edx,0x4(%esp)
80106856:	89 04 24             	mov    %eax,(%esp)
80106859:	e8 e2 a3 ff ff       	call   80100c40 <exec>
8010685e:	eb 33                	jmp    80106893 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106860:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106866:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106869:	c1 e2 02             	shl    $0x2,%edx
8010686c:	01 c2                	add    %eax,%edx
8010686e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106874:	89 54 24 04          	mov    %edx,0x4(%esp)
80106878:	89 04 24             	mov    %eax,(%esp)
8010687b:	e8 73 f1 ff ff       	call   801059f3 <fetchstr>
80106880:	85 c0                	test   %eax,%eax
80106882:	79 07                	jns    8010688b <sys_exec+0x103>
      return -1;
80106884:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106889:	eb 08                	jmp    80106893 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010688b:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010688e:	e9 5e ff ff ff       	jmp    801067f1 <sys_exec+0x69>
  return exec(path, argv);
}
80106893:	c9                   	leave  
80106894:	c3                   	ret    

80106895 <sys_pipe>:

int
sys_pipe(void)
{
80106895:	55                   	push   %ebp
80106896:	89 e5                	mov    %esp,%ebp
80106898:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010689b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801068a2:	00 
801068a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801068aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068b1:	e8 cc f1 ff ff       	call   80105a82 <argptr>
801068b6:	85 c0                	test   %eax,%eax
801068b8:	79 0a                	jns    801068c4 <sys_pipe+0x2f>
    return -1;
801068ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068bf:	e9 9a 00 00 00       	jmp    8010695e <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
801068c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801068c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801068cb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801068ce:	89 04 24             	mov    %eax,(%esp)
801068d1:	e8 5e d7 ff ff       	call   80104034 <pipealloc>
801068d6:	85 c0                	test   %eax,%eax
801068d8:	79 07                	jns    801068e1 <sys_pipe+0x4c>
    return -1;
801068da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068df:	eb 7d                	jmp    8010695e <sys_pipe+0xc9>
  fd0 = -1;
801068e1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801068e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068eb:	89 04 24             	mov    %eax,(%esp)
801068ee:	e8 2d f3 ff ff       	call   80105c20 <fdalloc>
801068f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068fa:	78 14                	js     80106910 <sys_pipe+0x7b>
801068fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068ff:	89 04 24             	mov    %eax,(%esp)
80106902:	e8 19 f3 ff ff       	call   80105c20 <fdalloc>
80106907:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010690a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010690e:	79 36                	jns    80106946 <sys_pipe+0xb1>
    if(fd0 >= 0)
80106910:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106914:	78 13                	js     80106929 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106916:	e8 c4 db ff ff       	call   801044df <myproc>
8010691b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010691e:	83 c2 08             	add    $0x8,%edx
80106921:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106928:	00 
    fileclose(rf);
80106929:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010692c:	89 04 24             	mov    %eax,(%esp)
8010692f:	e8 76 a8 ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106934:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106937:	89 04 24             	mov    %eax,(%esp)
8010693a:	e8 6b a8 ff ff       	call   801011aa <fileclose>
    return -1;
8010693f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106944:	eb 18                	jmp    8010695e <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106946:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106949:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010694c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010694e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106951:	8d 50 04             	lea    0x4(%eax),%edx
80106954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106957:	89 02                	mov    %eax,(%edx)
  return 0;
80106959:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010695e:	c9                   	leave  
8010695f:	c3                   	ret    

80106960 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106960:	55                   	push   %ebp
80106961:	89 e5                	mov    %esp,%ebp
80106963:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106966:	e8 74 db ff ff       	call   801044df <myproc>
8010696b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106971:	83 c0 18             	add    $0x18,%eax
80106974:	89 04 24             	mov    %eax,(%esp)
80106977:	e8 ef 27 00 00       	call   8010916b <find>
8010697c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
8010697f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106983:	78 51                	js     801069d6 <sys_fork+0x76>
    int before = get_curr_proc(x);
80106985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106988:	89 04 24             	mov    %eax,(%esp)
8010698b:	e8 33 29 00 00       	call   801092c3 <get_curr_proc>
80106990:	89 45 f0             	mov    %eax,-0x10(%ebp)
    set_curr_proc(1, x);
80106993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106996:	89 44 24 04          	mov    %eax,0x4(%esp)
8010699a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801069a1:	e8 01 2c 00 00       	call   801095a7 <set_curr_proc>
    int after = get_curr_proc(x);
801069a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a9:	89 04 24             	mov    %eax,(%esp)
801069ac:	e8 12 29 00 00       	call   801092c3 <get_curr_proc>
801069b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(after == before){
801069b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069b7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801069ba:	75 1a                	jne    801069d6 <sys_fork+0x76>
      cstop_container_helper(myproc()->cont);
801069bc:	e8 1e db ff ff       	call   801044df <myproc>
801069c1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801069c7:	89 04 24             	mov    %eax,(%esp)
801069ca:	e8 7d e6 ff ff       	call   8010504c <cstop_container_helper>
      return -1;
801069cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069d4:	eb 05                	jmp    801069db <sys_fork+0x7b>
    }
  }
  return fork();
801069d6:	e8 1d de ff ff       	call   801047f8 <fork>
}
801069db:	c9                   	leave  
801069dc:	c3                   	ret    

801069dd <sys_exit>:

int
sys_exit(void)
{
801069dd:	55                   	push   %ebp
801069de:	89 e5                	mov    %esp,%ebp
801069e0:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
801069e3:	e8 f7 da ff ff       	call   801044df <myproc>
801069e8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801069ee:	83 c0 18             	add    $0x18,%eax
801069f1:	89 04 24             	mov    %eax,(%esp)
801069f4:	e8 72 27 00 00       	call   8010916b <find>
801069f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
801069fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a00:	78 13                	js     80106a15 <sys_exit+0x38>
    set_curr_proc(-1, x);
80106a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a05:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a09:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
80106a10:	e8 92 2b 00 00       	call   801095a7 <set_curr_proc>
  }
  exit();
80106a15:	e8 56 df ff ff       	call   80104970 <exit>
  return 0;  // not reached
80106a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a1f:	c9                   	leave  
80106a20:	c3                   	ret    

80106a21 <sys_wait>:

int
sys_wait(void)
{
80106a21:	55                   	push   %ebp
80106a22:	89 e5                	mov    %esp,%ebp
80106a24:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106a27:	e8 88 e0 ff ff       	call   80104ab4 <wait>
}
80106a2c:	c9                   	leave  
80106a2d:	c3                   	ret    

80106a2e <sys_kill>:

int
sys_kill(void)
{
80106a2e:	55                   	push   %ebp
80106a2f:	89 e5                	mov    %esp,%ebp
80106a31:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106a34:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a37:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a42:	e8 0e f0 ff ff       	call   80105a55 <argint>
80106a47:	85 c0                	test   %eax,%eax
80106a49:	79 07                	jns    80106a52 <sys_kill+0x24>
    return -1;
80106a4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a50:	eb 0b                	jmp    80106a5d <sys_kill+0x2f>
  return kill(pid);
80106a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a55:	89 04 24             	mov    %eax,(%esp)
80106a58:	e8 35 e4 ff ff       	call   80104e92 <kill>
}
80106a5d:	c9                   	leave  
80106a5e:	c3                   	ret    

80106a5f <sys_getpid>:

int
sys_getpid(void)
{
80106a5f:	55                   	push   %ebp
80106a60:	89 e5                	mov    %esp,%ebp
80106a62:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106a65:	e8 75 da ff ff       	call   801044df <myproc>
80106a6a:	8b 40 10             	mov    0x10(%eax),%eax
}
80106a6d:	c9                   	leave  
80106a6e:	c3                   	ret    

80106a6f <sys_sbrk>:

int
sys_sbrk(void)
{
80106a6f:	55                   	push   %ebp
80106a70:	89 e5                	mov    %esp,%ebp
80106a72:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106a75:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a78:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a83:	e8 cd ef ff ff       	call   80105a55 <argint>
80106a88:	85 c0                	test   %eax,%eax
80106a8a:	79 07                	jns    80106a93 <sys_sbrk+0x24>
    return -1;
80106a8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a91:	eb 23                	jmp    80106ab6 <sys_sbrk+0x47>
  addr = myproc()->sz;
80106a93:	e8 47 da ff ff       	call   801044df <myproc>
80106a98:	8b 00                	mov    (%eax),%eax
80106a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aa0:	89 04 24             	mov    %eax,(%esp)
80106aa3:	e8 b2 dc ff ff       	call   8010475a <growproc>
80106aa8:	85 c0                	test   %eax,%eax
80106aaa:	79 07                	jns    80106ab3 <sys_sbrk+0x44>
    return -1;
80106aac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ab1:	eb 03                	jmp    80106ab6 <sys_sbrk+0x47>
  return addr;
80106ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106ab6:	c9                   	leave  
80106ab7:	c3                   	ret    

80106ab8 <sys_sleep>:

int
sys_sleep(void)
{
80106ab8:	55                   	push   %ebp
80106ab9:	89 e5                	mov    %esp,%ebp
80106abb:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106abe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ac5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106acc:	e8 84 ef ff ff       	call   80105a55 <argint>
80106ad1:	85 c0                	test   %eax,%eax
80106ad3:	79 07                	jns    80106adc <sys_sleep+0x24>
    return -1;
80106ad5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ada:	eb 6b                	jmp    80106b47 <sys_sleep+0x8f>
  acquire(&tickslock);
80106adc:	c7 04 24 80 83 11 80 	movl   $0x80118380,(%esp)
80106ae3:	e8 d7 e9 ff ff       	call   801054bf <acquire>
  ticks0 = ticks;
80106ae8:	a1 c0 8b 11 80       	mov    0x80118bc0,%eax
80106aed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106af0:	eb 33                	jmp    80106b25 <sys_sleep+0x6d>
    if(myproc()->killed){
80106af2:	e8 e8 d9 ff ff       	call   801044df <myproc>
80106af7:	8b 40 24             	mov    0x24(%eax),%eax
80106afa:	85 c0                	test   %eax,%eax
80106afc:	74 13                	je     80106b11 <sys_sleep+0x59>
      release(&tickslock);
80106afe:	c7 04 24 80 83 11 80 	movl   $0x80118380,(%esp)
80106b05:	e8 1f ea ff ff       	call   80105529 <release>
      return -1;
80106b0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b0f:	eb 36                	jmp    80106b47 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106b11:	c7 44 24 04 80 83 11 	movl   $0x80118380,0x4(%esp)
80106b18:	80 
80106b19:	c7 04 24 c0 8b 11 80 	movl   $0x80118bc0,(%esp)
80106b20:	e8 6b e2 ff ff       	call   80104d90 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106b25:	a1 c0 8b 11 80       	mov    0x80118bc0,%eax
80106b2a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106b2d:	89 c2                	mov    %eax,%edx
80106b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b32:	39 c2                	cmp    %eax,%edx
80106b34:	72 bc                	jb     80106af2 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106b36:	c7 04 24 80 83 11 80 	movl   $0x80118380,(%esp)
80106b3d:	e8 e7 e9 ff ff       	call   80105529 <release>
  return 0;
80106b42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b47:	c9                   	leave  
80106b48:	c3                   	ret    

80106b49 <sys_cstop>:

void sys_cstop(){
80106b49:	55                   	push   %ebp
80106b4a:	89 e5                	mov    %esp,%ebp
80106b4c:	53                   	push   %ebx
80106b4d:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
80106b50:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b53:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b5e:	e8 89 ef ff ff       	call   80105aec <argstr>

  if(myproc()->cont != NULL){
80106b63:	e8 77 d9 ff ff       	call   801044df <myproc>
80106b68:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106b6e:	85 c0                	test   %eax,%eax
80106b70:	74 72                	je     80106be4 <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
80106b72:	e8 68 d9 ff ff       	call   801044df <myproc>
80106b77:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
80106b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b83:	89 04 24             	mov    %eax,(%esp)
80106b86:	e8 ea ed ff ff       	call   80105975 <strlen>
80106b8b:	89 c3                	mov    %eax,%ebx
80106b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b90:	83 c0 18             	add    $0x18,%eax
80106b93:	89 04 24             	mov    %eax,(%esp)
80106b96:	e8 da ed ff ff       	call   80105975 <strlen>
80106b9b:	39 c3                	cmp    %eax,%ebx
80106b9d:	75 37                	jne    80106bd6 <sys_cstop+0x8d>
80106b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ba2:	89 04 24             	mov    %eax,(%esp)
80106ba5:	e8 cb ed ff ff       	call   80105975 <strlen>
80106baa:	89 c2                	mov    %eax,%edx
80106bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106baf:	8d 48 18             	lea    0x18(%eax),%ecx
80106bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bb5:	89 54 24 08          	mov    %edx,0x8(%esp)
80106bb9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106bbd:	89 04 24             	mov    %eax,(%esp)
80106bc0:	e8 c5 ec ff ff       	call   8010588a <strncmp>
80106bc5:	85 c0                	test   %eax,%eax
80106bc7:	75 0d                	jne    80106bd6 <sys_cstop+0x8d>
      cstop_container_helper(cont);
80106bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bcc:	89 04 24             	mov    %eax,(%esp)
80106bcf:	e8 78 e4 ff ff       	call   8010504c <cstop_container_helper>
80106bd4:	eb 19                	jmp    80106bef <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106bd6:	c7 04 24 44 9e 10 80 	movl   $0x80109e44,(%esp)
80106bdd:	e8 df 97 ff ff       	call   801003c1 <cprintf>
80106be2:	eb 0b                	jmp    80106bef <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106be7:	89 04 24             	mov    %eax,(%esp)
80106bea:	e8 c4 e4 ff ff       	call   801050b3 <cstop_helper>
  }

  //kill the processes with name as the id

}
80106bef:	83 c4 24             	add    $0x24,%esp
80106bf2:	5b                   	pop    %ebx
80106bf3:	5d                   	pop    %ebp
80106bf4:	c3                   	ret    

80106bf5 <sys_set_root_inode>:

void sys_set_root_inode(void){
80106bf5:	55                   	push   %ebp
80106bf6:	89 e5                	mov    %esp,%ebp
80106bf8:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
80106bfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c09:	e8 de ee ff ff       	call   80105aec <argstr>

  set_root_inode(name);
80106c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c11:	89 04 24             	mov    %eax,(%esp)
80106c14:	e8 3e 24 00 00       	call   80109057 <set_root_inode>
  cprintf("success\n");
80106c19:	c7 04 24 68 9e 10 80 	movl   $0x80109e68,(%esp)
80106c20:	e8 9c 97 ff ff       	call   801003c1 <cprintf>

}
80106c25:	c9                   	leave  
80106c26:	c3                   	ret    

80106c27 <sys_ps>:

void sys_ps(void){
80106c27:	55                   	push   %ebp
80106c28:	89 e5                	mov    %esp,%ebp
80106c2a:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
80106c2d:	e8 ad d8 ff ff       	call   801044df <myproc>
80106c32:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106c38:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80106c3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c3f:	75 07                	jne    80106c48 <sys_ps+0x21>
    procdump();
80106c41:	e8 c7 e2 ff ff       	call   80104f0d <procdump>
80106c46:	eb 0e                	jmp    80106c56 <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c4b:	83 c0 18             	add    $0x18,%eax
80106c4e:	89 04 24             	mov    %eax,(%esp)
80106c51:	e8 f3 e4 ff ff       	call   80105149 <c_procdump>
  }
}
80106c56:	c9                   	leave  
80106c57:	c3                   	ret    

80106c58 <sys_container_init>:

void sys_container_init(){
80106c58:	55                   	push   %ebp
80106c59:	89 e5                	mov    %esp,%ebp
80106c5b:	83 ec 08             	sub    $0x8,%esp
  container_init();
80106c5e:	e8 37 2a 00 00       	call   8010969a <container_init>
}
80106c63:	c9                   	leave  
80106c64:	c3                   	ret    

80106c65 <sys_is_full>:

int sys_is_full(void){
80106c65:	55                   	push   %ebp
80106c66:	89 e5                	mov    %esp,%ebp
80106c68:	83 ec 08             	sub    $0x8,%esp
  return is_full();
80106c6b:	e8 ab 24 00 00       	call   8010911b <is_full>
}
80106c70:	c9                   	leave  
80106c71:	c3                   	ret    

80106c72 <sys_find>:

int sys_find(void){
80106c72:	55                   	push   %ebp
80106c73:	89 e5                	mov    %esp,%ebp
80106c75:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106c78:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c86:	e8 61 ee ff ff       	call   80105aec <argstr>

  return find(name);
80106c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c8e:	89 04 24             	mov    %eax,(%esp)
80106c91:	e8 d5 24 00 00       	call   8010916b <find>
}
80106c96:	c9                   	leave  
80106c97:	c3                   	ret    

80106c98 <sys_get_name>:

void sys_get_name(void){
80106c98:	55                   	push   %ebp
80106c99:	89 e5                	mov    %esp,%ebp
80106c9b:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
80106c9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ca5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cac:	e8 a4 ed ff ff       	call   80105a55 <argint>
  argstr(1, &name);
80106cb1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cb8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106cbf:	e8 28 ee ff ff       	call   80105aec <argstr>

  get_name(vc_num, name);
80106cc4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cca:	89 54 24 04          	mov    %edx,0x4(%esp)
80106cce:	89 04 24             	mov    %eax,(%esp)
80106cd1:	e8 c2 23 00 00       	call   80109098 <get_name>
}
80106cd6:	c9                   	leave  
80106cd7:	c3                   	ret    

80106cd8 <sys_get_max_proc>:

int sys_get_max_proc(void){
80106cd8:	55                   	push   %ebp
80106cd9:	89 e5                	mov    %esp,%ebp
80106cdb:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106cde:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ce1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ce5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cec:	e8 64 ed ff ff       	call   80105a55 <argint>


  return get_max_proc(vc_num);  
80106cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cf4:	89 04 24             	mov    %eax,(%esp)
80106cf7:	e8 df 24 00 00       	call   801091db <get_max_proc>
}
80106cfc:	c9                   	leave  
80106cfd:	c3                   	ret    

80106cfe <sys_get_max_mem>:

int sys_get_max_mem(void){
80106cfe:	55                   	push   %ebp
80106cff:	89 e5                	mov    %esp,%ebp
80106d01:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d04:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d07:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d12:	e8 3e ed ff ff       	call   80105a55 <argint>


  return get_max_mem(vc_num);
80106d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d1a:	89 04 24             	mov    %eax,(%esp)
80106d1d:	e8 21 25 00 00       	call   80109243 <get_max_mem>
}
80106d22:	c9                   	leave  
80106d23:	c3                   	ret    

80106d24 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106d24:	55                   	push   %ebp
80106d25:	89 e5                	mov    %esp,%ebp
80106d27:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d38:	e8 18 ed ff ff       	call   80105a55 <argint>


  return get_max_disk(vc_num);
80106d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d40:	89 04 24             	mov    %eax,(%esp)
80106d43:	e8 3b 25 00 00       	call   80109283 <get_max_disk>

}
80106d48:	c9                   	leave  
80106d49:	c3                   	ret    

80106d4a <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106d4a:	55                   	push   %ebp
80106d4b:	89 e5                	mov    %esp,%ebp
80106d4d:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d50:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d53:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d5e:	e8 f2 ec ff ff       	call   80105a55 <argint>


  return get_curr_proc(vc_num);
80106d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d66:	89 04 24             	mov    %eax,(%esp)
80106d69:	e8 55 25 00 00       	call   801092c3 <get_curr_proc>
}
80106d6e:	c9                   	leave  
80106d6f:	c3                   	ret    

80106d70 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106d70:	55                   	push   %ebp
80106d71:	89 e5                	mov    %esp,%ebp
80106d73:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d76:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d79:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d84:	e8 cc ec ff ff       	call   80105a55 <argint>


  return get_curr_mem(vc_num);
80106d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d8c:	89 04 24             	mov    %eax,(%esp)
80106d8f:	e8 6f 25 00 00       	call   80109303 <get_curr_mem>
}
80106d94:	c9                   	leave  
80106d95:	c3                   	ret    

80106d96 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106d96:	55                   	push   %ebp
80106d97:	89 e5                	mov    %esp,%ebp
80106d99:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106da3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106daa:	e8 a6 ec ff ff       	call   80105a55 <argint>


  return get_curr_disk(vc_num);
80106daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106db2:	89 04 24             	mov    %eax,(%esp)
80106db5:	e8 89 25 00 00       	call   80109343 <get_curr_disk>
}
80106dba:	c9                   	leave  
80106dbb:	c3                   	ret    

80106dbc <sys_set_name>:

void sys_set_name(void){
80106dbc:	55                   	push   %ebp
80106dbd:	89 e5                	mov    %esp,%ebp
80106dbf:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106dc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106dd0:	e8 17 ed ff ff       	call   80105aec <argstr>

  int vc_num;
  argint(1, &vc_num);
80106dd5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dd8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ddc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106de3:	e8 6d ec ff ff       	call   80105a55 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80106de8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dee:	89 54 24 04          	mov    %edx,0x4(%esp)
80106df2:	89 04 24             	mov    %eax,(%esp)
80106df5:	e8 89 25 00 00       	call   80109383 <set_name>
  //cprintf("Done setting name.\n");
}
80106dfa:	c9                   	leave  
80106dfb:	c3                   	ret    

80106dfc <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80106dfc:	55                   	push   %ebp
80106dfd:	89 e5                	mov    %esp,%ebp
80106dff:	53                   	push   %ebx
80106e00:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106e03:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e06:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e11:	e8 3f ec ff ff       	call   80105a55 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106e16:	e8 c4 d6 ff ff       	call   801044df <myproc>
80106e1b:	89 c3                	mov    %eax,%ebx
80106e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e20:	89 04 24             	mov    %eax,(%esp)
80106e23:	e8 f3 23 00 00       	call   8010921b <get_container>
80106e28:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80106e2e:	83 c4 24             	add    $0x24,%esp
80106e31:	5b                   	pop    %ebx
80106e32:	5d                   	pop    %ebp
80106e33:	c3                   	ret    

80106e34 <sys_set_max_mem>:

void sys_set_max_mem(void){
80106e34:	55                   	push   %ebp
80106e35:	89 e5                	mov    %esp,%ebp
80106e37:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106e3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e48:	e8 08 ec ff ff       	call   80105a55 <argint>

  int vc_num;
  argint(1, &vc_num);
80106e4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e50:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e5b:	e8 f5 eb ff ff       	call   80105a55 <argint>

  set_max_mem(mem, vc_num);
80106e60:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e66:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e6a:	89 04 24             	mov    %eax,(%esp)
80106e6d:	e8 48 25 00 00       	call   801093ba <set_max_mem>
}
80106e72:	c9                   	leave  
80106e73:	c3                   	ret    

80106e74 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106e74:	55                   	push   %ebp
80106e75:	89 e5                	mov    %esp,%ebp
80106e77:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e88:	e8 c8 eb ff ff       	call   80105a55 <argint>

  int vc_num;
  argint(1, &vc_num);
80106e8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e90:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e9b:	e8 b5 eb ff ff       	call   80105a55 <argint>

  set_max_disk(disk, vc_num);
80106ea0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106eaa:	89 04 24             	mov    %eax,(%esp)
80106ead:	e8 2d 25 00 00       	call   801093df <set_max_disk>
}
80106eb2:	c9                   	leave  
80106eb3:	c3                   	ret    

80106eb4 <sys_set_max_proc>:

void sys_set_max_proc(void){
80106eb4:	55                   	push   %ebp
80106eb5:	89 e5                	mov    %esp,%ebp
80106eb7:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106eba:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ec1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ec8:	e8 88 eb ff ff       	call   80105a55 <argint>

  int vc_num;
  argint(1, &vc_num);
80106ecd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ed4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106edb:	e8 75 eb ff ff       	call   80105a55 <argint>

  set_max_proc(proc, vc_num);
80106ee0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106eea:	89 04 24             	mov    %eax,(%esp)
80106eed:	e8 13 25 00 00       	call   80109405 <set_max_proc>
}
80106ef2:	c9                   	leave  
80106ef3:	c3                   	ret    

80106ef4 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106ef4:	55                   	push   %ebp
80106ef5:	89 e5                	mov    %esp,%ebp
80106ef7:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106efa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106efd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f08:	e8 48 eb ff ff       	call   80105a55 <argint>

  int vc_num;
  argint(1, &vc_num);
80106f0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f10:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f1b:	e8 35 eb ff ff       	call   80105a55 <argint>

  set_curr_mem(mem, vc_num);
80106f20:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f26:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f2a:	89 04 24             	mov    %eax,(%esp)
80106f2d:	e8 f9 24 00 00       	call   8010942b <set_curr_mem>
}
80106f32:	c9                   	leave  
80106f33:	c3                   	ret    

80106f34 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80106f34:	55                   	push   %ebp
80106f35:	89 e5                	mov    %esp,%ebp
80106f37:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106f3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f48:	e8 08 eb ff ff       	call   80105a55 <argint>

  int vc_num;
  argint(1, &vc_num);
80106f4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f50:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f5b:	e8 f5 ea ff ff       	call   80105a55 <argint>

  set_curr_mem(mem, vc_num);
80106f60:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f66:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f6a:	89 04 24             	mov    %eax,(%esp)
80106f6d:	e8 b9 24 00 00       	call   8010942b <set_curr_mem>
}
80106f72:	c9                   	leave  
80106f73:	c3                   	ret    

80106f74 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106f74:	55                   	push   %ebp
80106f75:	89 e5                	mov    %esp,%ebp
80106f77:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106f7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f88:	e8 c8 ea ff ff       	call   80105a55 <argint>

  int vc_num;
  argint(1, &vc_num);
80106f8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f90:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f9b:	e8 b5 ea ff ff       	call   80105a55 <argint>

  set_curr_disk(disk, vc_num);
80106fa0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106faa:	89 04 24             	mov    %eax,(%esp)
80106fad:	e8 4e 25 00 00       	call   80109500 <set_curr_disk>
}
80106fb2:	c9                   	leave  
80106fb3:	c3                   	ret    

80106fb4 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106fb4:	55                   	push   %ebp
80106fb5:	89 e5                	mov    %esp,%ebp
80106fb7:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fc8:	e8 88 ea ff ff       	call   80105a55 <argint>

  int vc_num;
  argint(1, &vc_num);
80106fcd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fd4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106fdb:	e8 75 ea ff ff       	call   80105a55 <argint>

  set_curr_proc(proc, vc_num);
80106fe0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fea:	89 04 24             	mov    %eax,(%esp)
80106fed:	e8 b5 25 00 00       	call   801095a7 <set_curr_proc>
}
80106ff2:	c9                   	leave  
80106ff3:	c3                   	ret    

80106ff4 <sys_container_reset>:

void sys_container_reset(void){
80106ff4:	55                   	push   %ebp
80106ff5:	89 e5                	mov    %esp,%ebp
80106ff7:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(1, &vc_num);
80106ffa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
80107001:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107008:	e8 48 ea ff ff       	call   80105a55 <argint>
  container_reset(vc_num);
8010700d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107010:	89 04 24             	mov    %eax,(%esp)
80107013:	e8 97 27 00 00       	call   801097af <container_reset>
}
80107018:	c9                   	leave  
80107019:	c3                   	ret    

8010701a <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010701a:	55                   	push   %ebp
8010701b:	89 e5                	mov    %esp,%ebp
8010701d:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80107020:	c7 04 24 80 83 11 80 	movl   $0x80118380,(%esp)
80107027:	e8 93 e4 ff ff       	call   801054bf <acquire>
  xticks = ticks;
8010702c:	a1 c0 8b 11 80       	mov    0x80118bc0,%eax
80107031:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107034:	c7 04 24 80 83 11 80 	movl   $0x80118380,(%esp)
8010703b:	e8 e9 e4 ff ff       	call   80105529 <release>
  return xticks;
80107040:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107043:	c9                   	leave  
80107044:	c3                   	ret    

80107045 <sys_getticks>:

int
sys_getticks(void){
80107045:	55                   	push   %ebp
80107046:	89 e5                	mov    %esp,%ebp
80107048:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
8010704b:	e8 8f d4 ff ff       	call   801044df <myproc>
80107050:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80107053:	c9                   	leave  
80107054:	c3                   	ret    

80107055 <sys_max_containers>:

int sys_max_containers(void){
80107055:	55                   	push   %ebp
80107056:	89 e5                	mov    %esp,%ebp
80107058:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
8010705b:	e8 30 26 00 00       	call   80109690 <max_containers>
}
80107060:	c9                   	leave  
80107061:	c3                   	ret    

80107062 <sys_df>:


void sys_df(void){
80107062:	55                   	push   %ebp
80107063:	89 e5                	mov    %esp,%ebp
80107065:	53                   	push   %ebx
80107066:	83 ec 54             	sub    $0x54,%esp
  struct container* cont = myproc()->cont;
80107069:	e8 71 d4 ff ff       	call   801044df <myproc>
8010706e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107074:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct superblock sb;
  readsb(1, &sb);
80107077:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010707a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010707e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107085:	e8 36 a4 ff ff       	call   801014c0 <readsb>

  cprintf("nblocks: %d\n", sb.nblocks);
8010708a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010708d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107091:	c7 04 24 71 9e 10 80 	movl   $0x80109e71,(%esp)
80107098:	e8 24 93 ff ff       	call   801003c1 <cprintf>
  cprintf("nblocks: %d\n", FSSIZE);
8010709d:	c7 44 24 04 20 4e 00 	movl   $0x4e20,0x4(%esp)
801070a4:	00 
801070a5:	c7 04 24 71 9e 10 80 	movl   $0x80109e71,(%esp)
801070ac:	e8 10 93 ff ff       	call   801003c1 <cprintf>
  int used = 0;
801070b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
801070b8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801070bc:	75 52                	jne    80107110 <sys_df+0xae>
    int max = max_containers();
801070be:	e8 cd 25 00 00       	call   80109690 <max_containers>
801070c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
801070c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801070cd:	eb 1d                	jmp    801070ec <sys_df+0x8a>
      used = used + (int)(get_curr_disk(i) / 1024);
801070cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070d2:	89 04 24             	mov    %eax,(%esp)
801070d5:	e8 69 22 00 00       	call   80109343 <get_curr_disk>
801070da:	85 c0                	test   %eax,%eax
801070dc:	79 05                	jns    801070e3 <sys_df+0x81>
801070de:	05 ff 03 00 00       	add    $0x3ff,%eax
801070e3:	c1 f8 0a             	sar    $0xa,%eax
801070e6:	01 45 f4             	add    %eax,-0xc(%ebp)
  cprintf("nblocks: %d\n", FSSIZE);
  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
801070e9:	ff 45 f0             	incl   -0x10(%ebp)
801070ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070ef:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801070f2:	7c db                	jl     801070cf <sys_df+0x6d>
      used = used + (int)(get_curr_disk(i) / 1024);
    }
    cprintf("Total Disk Used: ~%d / Total Disk Available: %d\n", used, sb.nblocks);
801070f4:	8b 45 c8             	mov    -0x38(%ebp),%eax
801070f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801070fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80107102:	c7 04 24 80 9e 10 80 	movl   $0x80109e80,(%esp)
80107109:	e8 b3 92 ff ff       	call   801003c1 <cprintf>
8010710e:	eb 5e                	jmp    8010716e <sys_df+0x10c>
  }
  else{
    int x = find(cont->name);
80107110:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107113:	83 c0 18             	add    $0x18,%eax
80107116:	89 04 24             	mov    %eax,(%esp)
80107119:	e8 4d 20 00 00       	call   8010916b <find>
8010711e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
80107121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107124:	89 04 24             	mov    %eax,(%esp)
80107127:	e8 17 22 00 00       	call   80109343 <get_curr_disk>
8010712c:	85 c0                	test   %eax,%eax
8010712e:	79 05                	jns    80107135 <sys_df+0xd3>
80107130:	05 ff 03 00 00       	add    $0x3ff,%eax
80107135:	c1 f8 0a             	sar    $0xa,%eax
80107138:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("Disk Used: ~%d -- %d  / Disk Available: %d\n", used, get_curr_disk(x),  get_max_disk(x));
8010713b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010713e:	89 04 24             	mov    %eax,(%esp)
80107141:	e8 3d 21 00 00       	call   80109283 <get_max_disk>
80107146:	89 c3                	mov    %eax,%ebx
80107148:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010714b:	89 04 24             	mov    %eax,(%esp)
8010714e:	e8 f0 21 00 00       	call   80109343 <get_curr_disk>
80107153:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80107157:	89 44 24 08          	mov    %eax,0x8(%esp)
8010715b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010715e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107162:	c7 04 24 b4 9e 10 80 	movl   $0x80109eb4,(%esp)
80107169:	e8 53 92 ff ff       	call   801003c1 <cprintf>
  }
}
8010716e:	83 c4 54             	add    $0x54,%esp
80107171:	5b                   	pop    %ebx
80107172:	5d                   	pop    %ebp
80107173:	c3                   	ret    

80107174 <sys_pause>:



void
sys_pause(void){
80107174:	55                   	push   %ebp
80107175:	89 e5                	mov    %esp,%ebp
80107177:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
8010717a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010717d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107188:	e8 5f e9 ff ff       	call   80105aec <argstr>
  pause(name);
8010718d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107190:	89 04 24             	mov    %eax,(%esp)
80107193:	e8 f7 e0 ff ff       	call   8010528f <pause>
}
80107198:	c9                   	leave  
80107199:	c3                   	ret    

8010719a <sys_resume>:

void
sys_resume(void){
8010719a:	55                   	push   %ebp
8010719b:	89 e5                	mov    %esp,%ebp
8010719d:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
801071a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801071a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071ae:	e8 39 e9 ff ff       	call   80105aec <argstr>
  resume(name);
801071b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b6:	89 04 24             	mov    %eax,(%esp)
801071b9:	e8 34 e1 ff ff       	call   801052f2 <resume>
}
801071be:	c9                   	leave  
801071bf:	c3                   	ret    

801071c0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801071c0:	1e                   	push   %ds
  pushl %es
801071c1:	06                   	push   %es
  pushl %fs
801071c2:	0f a0                	push   %fs
  pushl %gs
801071c4:	0f a8                	push   %gs
  pushal
801071c6:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801071c7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801071cb:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801071cd:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801071cf:	54                   	push   %esp
  call trap
801071d0:	e8 c0 01 00 00       	call   80107395 <trap>
  addl $4, %esp
801071d5:	83 c4 04             	add    $0x4,%esp

801071d8 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801071d8:	61                   	popa   
  popl %gs
801071d9:	0f a9                	pop    %gs
  popl %fs
801071db:	0f a1                	pop    %fs
  popl %es
801071dd:	07                   	pop    %es
  popl %ds
801071de:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801071df:	83 c4 08             	add    $0x8,%esp
  iret
801071e2:	cf                   	iret   
	...

801071e4 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801071e4:	55                   	push   %ebp
801071e5:	89 e5                	mov    %esp,%ebp
801071e7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801071ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801071ed:	48                   	dec    %eax
801071ee:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801071f2:	8b 45 08             	mov    0x8(%ebp),%eax
801071f5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801071f9:	8b 45 08             	mov    0x8(%ebp),%eax
801071fc:	c1 e8 10             	shr    $0x10,%eax
801071ff:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107203:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107206:	0f 01 18             	lidtl  (%eax)
}
80107209:	c9                   	leave  
8010720a:	c3                   	ret    

8010720b <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010720b:	55                   	push   %ebp
8010720c:	89 e5                	mov    %esp,%ebp
8010720e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107211:	0f 20 d0             	mov    %cr2,%eax
80107214:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107217:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010721a:	c9                   	leave  
8010721b:	c3                   	ret    

8010721c <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010721c:	55                   	push   %ebp
8010721d:	89 e5                	mov    %esp,%ebp
8010721f:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80107222:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107229:	e9 b8 00 00 00       	jmp    801072e6 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010722e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107231:	8b 04 85 08 d1 10 80 	mov    -0x7fef2ef8(,%eax,4),%eax
80107238:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010723b:	66 89 04 d5 c0 83 11 	mov    %ax,-0x7fee7c40(,%edx,8)
80107242:	80 
80107243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107246:	66 c7 04 c5 c2 83 11 	movw   $0x8,-0x7fee7c3e(,%eax,8)
8010724d:	80 08 00 
80107250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107253:	8a 14 c5 c4 83 11 80 	mov    -0x7fee7c3c(,%eax,8),%dl
8010725a:	83 e2 e0             	and    $0xffffffe0,%edx
8010725d:	88 14 c5 c4 83 11 80 	mov    %dl,-0x7fee7c3c(,%eax,8)
80107264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107267:	8a 14 c5 c4 83 11 80 	mov    -0x7fee7c3c(,%eax,8),%dl
8010726e:	83 e2 1f             	and    $0x1f,%edx
80107271:	88 14 c5 c4 83 11 80 	mov    %dl,-0x7fee7c3c(,%eax,8)
80107278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727b:	8a 14 c5 c5 83 11 80 	mov    -0x7fee7c3b(,%eax,8),%dl
80107282:	83 e2 f0             	and    $0xfffffff0,%edx
80107285:	83 ca 0e             	or     $0xe,%edx
80107288:	88 14 c5 c5 83 11 80 	mov    %dl,-0x7fee7c3b(,%eax,8)
8010728f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107292:	8a 14 c5 c5 83 11 80 	mov    -0x7fee7c3b(,%eax,8),%dl
80107299:	83 e2 ef             	and    $0xffffffef,%edx
8010729c:	88 14 c5 c5 83 11 80 	mov    %dl,-0x7fee7c3b(,%eax,8)
801072a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a6:	8a 14 c5 c5 83 11 80 	mov    -0x7fee7c3b(,%eax,8),%dl
801072ad:	83 e2 9f             	and    $0xffffff9f,%edx
801072b0:	88 14 c5 c5 83 11 80 	mov    %dl,-0x7fee7c3b(,%eax,8)
801072b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ba:	8a 14 c5 c5 83 11 80 	mov    -0x7fee7c3b(,%eax,8),%dl
801072c1:	83 ca 80             	or     $0xffffff80,%edx
801072c4:	88 14 c5 c5 83 11 80 	mov    %dl,-0x7fee7c3b(,%eax,8)
801072cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ce:	8b 04 85 08 d1 10 80 	mov    -0x7fef2ef8(,%eax,4),%eax
801072d5:	c1 e8 10             	shr    $0x10,%eax
801072d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801072db:	66 89 04 d5 c6 83 11 	mov    %ax,-0x7fee7c3a(,%edx,8)
801072e2:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801072e3:	ff 45 f4             	incl   -0xc(%ebp)
801072e6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801072ed:	0f 8e 3b ff ff ff    	jle    8010722e <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801072f3:	a1 08 d2 10 80       	mov    0x8010d208,%eax
801072f8:	66 a3 c0 85 11 80    	mov    %ax,0x801185c0
801072fe:	66 c7 05 c2 85 11 80 	movw   $0x8,0x801185c2
80107305:	08 00 
80107307:	a0 c4 85 11 80       	mov    0x801185c4,%al
8010730c:	83 e0 e0             	and    $0xffffffe0,%eax
8010730f:	a2 c4 85 11 80       	mov    %al,0x801185c4
80107314:	a0 c4 85 11 80       	mov    0x801185c4,%al
80107319:	83 e0 1f             	and    $0x1f,%eax
8010731c:	a2 c4 85 11 80       	mov    %al,0x801185c4
80107321:	a0 c5 85 11 80       	mov    0x801185c5,%al
80107326:	83 c8 0f             	or     $0xf,%eax
80107329:	a2 c5 85 11 80       	mov    %al,0x801185c5
8010732e:	a0 c5 85 11 80       	mov    0x801185c5,%al
80107333:	83 e0 ef             	and    $0xffffffef,%eax
80107336:	a2 c5 85 11 80       	mov    %al,0x801185c5
8010733b:	a0 c5 85 11 80       	mov    0x801185c5,%al
80107340:	83 c8 60             	or     $0x60,%eax
80107343:	a2 c5 85 11 80       	mov    %al,0x801185c5
80107348:	a0 c5 85 11 80       	mov    0x801185c5,%al
8010734d:	83 c8 80             	or     $0xffffff80,%eax
80107350:	a2 c5 85 11 80       	mov    %al,0x801185c5
80107355:	a1 08 d2 10 80       	mov    0x8010d208,%eax
8010735a:	c1 e8 10             	shr    $0x10,%eax
8010735d:	66 a3 c6 85 11 80    	mov    %ax,0x801185c6

  initlock(&tickslock, "time");
80107363:	c7 44 24 04 e0 9e 10 	movl   $0x80109ee0,0x4(%esp)
8010736a:	80 
8010736b:	c7 04 24 80 83 11 80 	movl   $0x80118380,(%esp)
80107372:	e8 27 e1 ff ff       	call   8010549e <initlock>
}
80107377:	c9                   	leave  
80107378:	c3                   	ret    

80107379 <idtinit>:

void
idtinit(void)
{
80107379:	55                   	push   %ebp
8010737a:	89 e5                	mov    %esp,%ebp
8010737c:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010737f:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80107386:	00 
80107387:	c7 04 24 c0 83 11 80 	movl   $0x801183c0,(%esp)
8010738e:	e8 51 fe ff ff       	call   801071e4 <lidt>
}
80107393:	c9                   	leave  
80107394:	c3                   	ret    

80107395 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107395:	55                   	push   %ebp
80107396:	89 e5                	mov    %esp,%ebp
80107398:	57                   	push   %edi
80107399:	56                   	push   %esi
8010739a:	53                   	push   %ebx
8010739b:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
8010739e:	8b 45 08             	mov    0x8(%ebp),%eax
801073a1:	8b 40 30             	mov    0x30(%eax),%eax
801073a4:	83 f8 40             	cmp    $0x40,%eax
801073a7:	75 3c                	jne    801073e5 <trap+0x50>
    if(myproc()->killed)
801073a9:	e8 31 d1 ff ff       	call   801044df <myproc>
801073ae:	8b 40 24             	mov    0x24(%eax),%eax
801073b1:	85 c0                	test   %eax,%eax
801073b3:	74 05                	je     801073ba <trap+0x25>
      exit();
801073b5:	e8 b6 d5 ff ff       	call   80104970 <exit>
    myproc()->tf = tf;
801073ba:	e8 20 d1 ff ff       	call   801044df <myproc>
801073bf:	8b 55 08             	mov    0x8(%ebp),%edx
801073c2:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801073c5:	e8 59 e7 ff ff       	call   80105b23 <syscall>
    if(myproc()->killed)
801073ca:	e8 10 d1 ff ff       	call   801044df <myproc>
801073cf:	8b 40 24             	mov    0x24(%eax),%eax
801073d2:	85 c0                	test   %eax,%eax
801073d4:	74 0a                	je     801073e0 <trap+0x4b>
      exit();
801073d6:	e8 95 d5 ff ff       	call   80104970 <exit>
    return;
801073db:	e9 30 02 00 00       	jmp    80107610 <trap+0x27b>
801073e0:	e9 2b 02 00 00       	jmp    80107610 <trap+0x27b>
  }

  switch(tf->trapno){
801073e5:	8b 45 08             	mov    0x8(%ebp),%eax
801073e8:	8b 40 30             	mov    0x30(%eax),%eax
801073eb:	83 e8 20             	sub    $0x20,%eax
801073ee:	83 f8 1f             	cmp    $0x1f,%eax
801073f1:	0f 87 cb 00 00 00    	ja     801074c2 <trap+0x12d>
801073f7:	8b 04 85 88 9f 10 80 	mov    -0x7fef6078(,%eax,4),%eax
801073fe:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80107400:	e8 11 d0 ff ff       	call   80104416 <cpuid>
80107405:	85 c0                	test   %eax,%eax
80107407:	75 2f                	jne    80107438 <trap+0xa3>
      acquire(&tickslock);
80107409:	c7 04 24 80 83 11 80 	movl   $0x80118380,(%esp)
80107410:	e8 aa e0 ff ff       	call   801054bf <acquire>
      ticks++;
80107415:	a1 c0 8b 11 80       	mov    0x80118bc0,%eax
8010741a:	40                   	inc    %eax
8010741b:	a3 c0 8b 11 80       	mov    %eax,0x80118bc0
      wakeup(&ticks);
80107420:	c7 04 24 c0 8b 11 80 	movl   $0x80118bc0,(%esp)
80107427:	e8 3b da ff ff       	call   80104e67 <wakeup>
      release(&tickslock);
8010742c:	c7 04 24 80 83 11 80 	movl   $0x80118380,(%esp)
80107433:	e8 f1 e0 ff ff       	call   80105529 <release>
    }
    p = myproc();
80107438:	e8 a2 d0 ff ff       	call   801044df <myproc>
8010743d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80107440:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80107444:	74 0f                	je     80107455 <trap+0xc0>
      p->ticks++;
80107446:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107449:	8b 40 7c             	mov    0x7c(%eax),%eax
8010744c:	8d 50 01             	lea    0x1(%eax),%edx
8010744f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107452:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80107455:	e8 5d be ff ff       	call   801032b7 <lapiceoi>
    break;
8010745a:	e9 35 01 00 00       	jmp    80107594 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010745f:	e8 1e b6 ff ff       	call   80102a82 <ideintr>
    lapiceoi();
80107464:	e8 4e be ff ff       	call   801032b7 <lapiceoi>
    break;
80107469:	e9 26 01 00 00       	jmp    80107594 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010746e:	e8 5b bc ff ff       	call   801030ce <kbdintr>
    lapiceoi();
80107473:	e8 3f be ff ff       	call   801032b7 <lapiceoi>
    break;
80107478:	e9 17 01 00 00       	jmp    80107594 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010747d:	e8 6f 03 00 00       	call   801077f1 <uartintr>
    lapiceoi();
80107482:	e8 30 be ff ff       	call   801032b7 <lapiceoi>
    break;
80107487:	e9 08 01 00 00       	jmp    80107594 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010748c:	8b 45 08             	mov    0x8(%ebp),%eax
8010748f:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80107492:	8b 45 08             	mov    0x8(%ebp),%eax
80107495:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107498:	0f b7 d8             	movzwl %ax,%ebx
8010749b:	e8 76 cf ff ff       	call   80104416 <cpuid>
801074a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
801074a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801074a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801074ac:	c7 04 24 e8 9e 10 80 	movl   $0x80109ee8,(%esp)
801074b3:	e8 09 8f ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
801074b8:	e8 fa bd ff ff       	call   801032b7 <lapiceoi>
    break;
801074bd:	e9 d2 00 00 00       	jmp    80107594 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801074c2:	e8 18 d0 ff ff       	call   801044df <myproc>
801074c7:	85 c0                	test   %eax,%eax
801074c9:	74 10                	je     801074db <trap+0x146>
801074cb:	8b 45 08             	mov    0x8(%ebp),%eax
801074ce:	8b 40 3c             	mov    0x3c(%eax),%eax
801074d1:	0f b7 c0             	movzwl %ax,%eax
801074d4:	83 e0 03             	and    $0x3,%eax
801074d7:	85 c0                	test   %eax,%eax
801074d9:	75 40                	jne    8010751b <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801074db:	e8 2b fd ff ff       	call   8010720b <rcr2>
801074e0:	89 c3                	mov    %eax,%ebx
801074e2:	8b 45 08             	mov    0x8(%ebp),%eax
801074e5:	8b 70 38             	mov    0x38(%eax),%esi
801074e8:	e8 29 cf ff ff       	call   80104416 <cpuid>
801074ed:	8b 55 08             	mov    0x8(%ebp),%edx
801074f0:	8b 52 30             	mov    0x30(%edx),%edx
801074f3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801074f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
801074fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801074ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80107503:	c7 04 24 0c 9f 10 80 	movl   $0x80109f0c,(%esp)
8010750a:	e8 b2 8e ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010750f:	c7 04 24 3e 9f 10 80 	movl   $0x80109f3e,(%esp)
80107516:	e8 39 90 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010751b:	e8 eb fc ff ff       	call   8010720b <rcr2>
80107520:	89 c6                	mov    %eax,%esi
80107522:	8b 45 08             	mov    0x8(%ebp),%eax
80107525:	8b 40 38             	mov    0x38(%eax),%eax
80107528:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010752b:	e8 e6 ce ff ff       	call   80104416 <cpuid>
80107530:	89 c3                	mov    %eax,%ebx
80107532:	8b 45 08             	mov    0x8(%ebp),%eax
80107535:	8b 78 34             	mov    0x34(%eax),%edi
80107538:	89 7d d0             	mov    %edi,-0x30(%ebp)
8010753b:	8b 45 08             	mov    0x8(%ebp),%eax
8010753e:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80107541:	e8 99 cf ff ff       	call   801044df <myproc>
80107546:	8d 50 6c             	lea    0x6c(%eax),%edx
80107549:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010754c:	e8 8e cf ff ff       	call   801044df <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107551:	8b 40 10             	mov    0x10(%eax),%eax
80107554:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80107558:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
8010755b:	89 4c 24 18          	mov    %ecx,0x18(%esp)
8010755f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80107563:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80107566:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010756a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
8010756e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80107571:	89 54 24 08          	mov    %edx,0x8(%esp)
80107575:	89 44 24 04          	mov    %eax,0x4(%esp)
80107579:	c7 04 24 44 9f 10 80 	movl   $0x80109f44,(%esp)
80107580:	e8 3c 8e ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80107585:	e8 55 cf ff ff       	call   801044df <myproc>
8010758a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107591:	eb 01                	jmp    80107594 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107593:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107594:	e8 46 cf ff ff       	call   801044df <myproc>
80107599:	85 c0                	test   %eax,%eax
8010759b:	74 22                	je     801075bf <trap+0x22a>
8010759d:	e8 3d cf ff ff       	call   801044df <myproc>
801075a2:	8b 40 24             	mov    0x24(%eax),%eax
801075a5:	85 c0                	test   %eax,%eax
801075a7:	74 16                	je     801075bf <trap+0x22a>
801075a9:	8b 45 08             	mov    0x8(%ebp),%eax
801075ac:	8b 40 3c             	mov    0x3c(%eax),%eax
801075af:	0f b7 c0             	movzwl %ax,%eax
801075b2:	83 e0 03             	and    $0x3,%eax
801075b5:	83 f8 03             	cmp    $0x3,%eax
801075b8:	75 05                	jne    801075bf <trap+0x22a>
    exit();
801075ba:	e8 b1 d3 ff ff       	call   80104970 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801075bf:	e8 1b cf ff ff       	call   801044df <myproc>
801075c4:	85 c0                	test   %eax,%eax
801075c6:	74 1d                	je     801075e5 <trap+0x250>
801075c8:	e8 12 cf ff ff       	call   801044df <myproc>
801075cd:	8b 40 0c             	mov    0xc(%eax),%eax
801075d0:	83 f8 04             	cmp    $0x4,%eax
801075d3:	75 10                	jne    801075e5 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801075d5:	8b 45 08             	mov    0x8(%ebp),%eax
801075d8:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801075db:	83 f8 20             	cmp    $0x20,%eax
801075de:	75 05                	jne    801075e5 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
801075e0:	e8 3b d7 ff ff       	call   80104d20 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801075e5:	e8 f5 ce ff ff       	call   801044df <myproc>
801075ea:	85 c0                	test   %eax,%eax
801075ec:	74 22                	je     80107610 <trap+0x27b>
801075ee:	e8 ec ce ff ff       	call   801044df <myproc>
801075f3:	8b 40 24             	mov    0x24(%eax),%eax
801075f6:	85 c0                	test   %eax,%eax
801075f8:	74 16                	je     80107610 <trap+0x27b>
801075fa:	8b 45 08             	mov    0x8(%ebp),%eax
801075fd:	8b 40 3c             	mov    0x3c(%eax),%eax
80107600:	0f b7 c0             	movzwl %ax,%eax
80107603:	83 e0 03             	and    $0x3,%eax
80107606:	83 f8 03             	cmp    $0x3,%eax
80107609:	75 05                	jne    80107610 <trap+0x27b>
    exit();
8010760b:	e8 60 d3 ff ff       	call   80104970 <exit>
}
80107610:	83 c4 4c             	add    $0x4c,%esp
80107613:	5b                   	pop    %ebx
80107614:	5e                   	pop    %esi
80107615:	5f                   	pop    %edi
80107616:	5d                   	pop    %ebp
80107617:	c3                   	ret    

80107618 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107618:	55                   	push   %ebp
80107619:	89 e5                	mov    %esp,%ebp
8010761b:	83 ec 14             	sub    $0x14,%esp
8010761e:	8b 45 08             	mov    0x8(%ebp),%eax
80107621:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107625:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107628:	89 c2                	mov    %eax,%edx
8010762a:	ec                   	in     (%dx),%al
8010762b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010762e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80107631:	c9                   	leave  
80107632:	c3                   	ret    

80107633 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107633:	55                   	push   %ebp
80107634:	89 e5                	mov    %esp,%ebp
80107636:	83 ec 08             	sub    $0x8,%esp
80107639:	8b 45 08             	mov    0x8(%ebp),%eax
8010763c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010763f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107643:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107646:	8a 45 f8             	mov    -0x8(%ebp),%al
80107649:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010764c:	ee                   	out    %al,(%dx)
}
8010764d:	c9                   	leave  
8010764e:	c3                   	ret    

8010764f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010764f:	55                   	push   %ebp
80107650:	89 e5                	mov    %esp,%ebp
80107652:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107655:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010765c:	00 
8010765d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107664:	e8 ca ff ff ff       	call   80107633 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107669:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107670:	00 
80107671:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107678:	e8 b6 ff ff ff       	call   80107633 <outb>
  outb(COM1+0, 115200/9600);
8010767d:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107684:	00 
80107685:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010768c:	e8 a2 ff ff ff       	call   80107633 <outb>
  outb(COM1+1, 0);
80107691:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107698:	00 
80107699:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801076a0:	e8 8e ff ff ff       	call   80107633 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801076a5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801076ac:	00 
801076ad:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801076b4:	e8 7a ff ff ff       	call   80107633 <outb>
  outb(COM1+4, 0);
801076b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801076c0:	00 
801076c1:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801076c8:	e8 66 ff ff ff       	call   80107633 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801076cd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801076d4:	00 
801076d5:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801076dc:	e8 52 ff ff ff       	call   80107633 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801076e1:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801076e8:	e8 2b ff ff ff       	call   80107618 <inb>
801076ed:	3c ff                	cmp    $0xff,%al
801076ef:	75 02                	jne    801076f3 <uartinit+0xa4>
    return;
801076f1:	eb 5b                	jmp    8010774e <uartinit+0xff>
  uart = 1;
801076f3:	c7 05 24 d9 10 80 01 	movl   $0x1,0x8010d924
801076fa:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801076fd:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107704:	e8 0f ff ff ff       	call   80107618 <inb>
  inb(COM1+0);
80107709:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107710:	e8 03 ff ff ff       	call   80107618 <inb>
  ioapicenable(IRQ_COM1, 0);
80107715:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010771c:	00 
8010771d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107724:	e8 ce b5 ff ff       	call   80102cf7 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107729:	c7 45 f4 08 a0 10 80 	movl   $0x8010a008,-0xc(%ebp)
80107730:	eb 13                	jmp    80107745 <uartinit+0xf6>
    uartputc(*p);
80107732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107735:	8a 00                	mov    (%eax),%al
80107737:	0f be c0             	movsbl %al,%eax
8010773a:	89 04 24             	mov    %eax,(%esp)
8010773d:	e8 0e 00 00 00       	call   80107750 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107742:	ff 45 f4             	incl   -0xc(%ebp)
80107745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107748:	8a 00                	mov    (%eax),%al
8010774a:	84 c0                	test   %al,%al
8010774c:	75 e4                	jne    80107732 <uartinit+0xe3>
    uartputc(*p);
}
8010774e:	c9                   	leave  
8010774f:	c3                   	ret    

80107750 <uartputc>:

void
uartputc(int c)
{
80107750:	55                   	push   %ebp
80107751:	89 e5                	mov    %esp,%ebp
80107753:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107756:	a1 24 d9 10 80       	mov    0x8010d924,%eax
8010775b:	85 c0                	test   %eax,%eax
8010775d:	75 02                	jne    80107761 <uartputc+0x11>
    return;
8010775f:	eb 4a                	jmp    801077ab <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107761:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107768:	eb 0f                	jmp    80107779 <uartputc+0x29>
    microdelay(10);
8010776a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107771:	e8 66 bb ff ff       	call   801032dc <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107776:	ff 45 f4             	incl   -0xc(%ebp)
80107779:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010777d:	7f 16                	jg     80107795 <uartputc+0x45>
8010777f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107786:	e8 8d fe ff ff       	call   80107618 <inb>
8010778b:	0f b6 c0             	movzbl %al,%eax
8010778e:	83 e0 20             	and    $0x20,%eax
80107791:	85 c0                	test   %eax,%eax
80107793:	74 d5                	je     8010776a <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107795:	8b 45 08             	mov    0x8(%ebp),%eax
80107798:	0f b6 c0             	movzbl %al,%eax
8010779b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010779f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801077a6:	e8 88 fe ff ff       	call   80107633 <outb>
}
801077ab:	c9                   	leave  
801077ac:	c3                   	ret    

801077ad <uartgetc>:

static int
uartgetc(void)
{
801077ad:	55                   	push   %ebp
801077ae:	89 e5                	mov    %esp,%ebp
801077b0:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801077b3:	a1 24 d9 10 80       	mov    0x8010d924,%eax
801077b8:	85 c0                	test   %eax,%eax
801077ba:	75 07                	jne    801077c3 <uartgetc+0x16>
    return -1;
801077bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077c1:	eb 2c                	jmp    801077ef <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801077c3:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801077ca:	e8 49 fe ff ff       	call   80107618 <inb>
801077cf:	0f b6 c0             	movzbl %al,%eax
801077d2:	83 e0 01             	and    $0x1,%eax
801077d5:	85 c0                	test   %eax,%eax
801077d7:	75 07                	jne    801077e0 <uartgetc+0x33>
    return -1;
801077d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077de:	eb 0f                	jmp    801077ef <uartgetc+0x42>
  return inb(COM1+0);
801077e0:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801077e7:	e8 2c fe ff ff       	call   80107618 <inb>
801077ec:	0f b6 c0             	movzbl %al,%eax
}
801077ef:	c9                   	leave  
801077f0:	c3                   	ret    

801077f1 <uartintr>:

void
uartintr(void)
{
801077f1:	55                   	push   %ebp
801077f2:	89 e5                	mov    %esp,%ebp
801077f4:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801077f7:	c7 04 24 ad 77 10 80 	movl   $0x801077ad,(%esp)
801077fe:	e8 f2 8f ff ff       	call   801007f5 <consoleintr>
}
80107803:	c9                   	leave  
80107804:	c3                   	ret    
80107805:	00 00                	add    %al,(%eax)
	...

80107808 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $0
8010780a:	6a 00                	push   $0x0
  jmp alltraps
8010780c:	e9 af f9 ff ff       	jmp    801071c0 <alltraps>

80107811 <vector1>:
.globl vector1
vector1:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $1
80107813:	6a 01                	push   $0x1
  jmp alltraps
80107815:	e9 a6 f9 ff ff       	jmp    801071c0 <alltraps>

8010781a <vector2>:
.globl vector2
vector2:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $2
8010781c:	6a 02                	push   $0x2
  jmp alltraps
8010781e:	e9 9d f9 ff ff       	jmp    801071c0 <alltraps>

80107823 <vector3>:
.globl vector3
vector3:
  pushl $0
80107823:	6a 00                	push   $0x0
  pushl $3
80107825:	6a 03                	push   $0x3
  jmp alltraps
80107827:	e9 94 f9 ff ff       	jmp    801071c0 <alltraps>

8010782c <vector4>:
.globl vector4
vector4:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $4
8010782e:	6a 04                	push   $0x4
  jmp alltraps
80107830:	e9 8b f9 ff ff       	jmp    801071c0 <alltraps>

80107835 <vector5>:
.globl vector5
vector5:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $5
80107837:	6a 05                	push   $0x5
  jmp alltraps
80107839:	e9 82 f9 ff ff       	jmp    801071c0 <alltraps>

8010783e <vector6>:
.globl vector6
vector6:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $6
80107840:	6a 06                	push   $0x6
  jmp alltraps
80107842:	e9 79 f9 ff ff       	jmp    801071c0 <alltraps>

80107847 <vector7>:
.globl vector7
vector7:
  pushl $0
80107847:	6a 00                	push   $0x0
  pushl $7
80107849:	6a 07                	push   $0x7
  jmp alltraps
8010784b:	e9 70 f9 ff ff       	jmp    801071c0 <alltraps>

80107850 <vector8>:
.globl vector8
vector8:
  pushl $8
80107850:	6a 08                	push   $0x8
  jmp alltraps
80107852:	e9 69 f9 ff ff       	jmp    801071c0 <alltraps>

80107857 <vector9>:
.globl vector9
vector9:
  pushl $0
80107857:	6a 00                	push   $0x0
  pushl $9
80107859:	6a 09                	push   $0x9
  jmp alltraps
8010785b:	e9 60 f9 ff ff       	jmp    801071c0 <alltraps>

80107860 <vector10>:
.globl vector10
vector10:
  pushl $10
80107860:	6a 0a                	push   $0xa
  jmp alltraps
80107862:	e9 59 f9 ff ff       	jmp    801071c0 <alltraps>

80107867 <vector11>:
.globl vector11
vector11:
  pushl $11
80107867:	6a 0b                	push   $0xb
  jmp alltraps
80107869:	e9 52 f9 ff ff       	jmp    801071c0 <alltraps>

8010786e <vector12>:
.globl vector12
vector12:
  pushl $12
8010786e:	6a 0c                	push   $0xc
  jmp alltraps
80107870:	e9 4b f9 ff ff       	jmp    801071c0 <alltraps>

80107875 <vector13>:
.globl vector13
vector13:
  pushl $13
80107875:	6a 0d                	push   $0xd
  jmp alltraps
80107877:	e9 44 f9 ff ff       	jmp    801071c0 <alltraps>

8010787c <vector14>:
.globl vector14
vector14:
  pushl $14
8010787c:	6a 0e                	push   $0xe
  jmp alltraps
8010787e:	e9 3d f9 ff ff       	jmp    801071c0 <alltraps>

80107883 <vector15>:
.globl vector15
vector15:
  pushl $0
80107883:	6a 00                	push   $0x0
  pushl $15
80107885:	6a 0f                	push   $0xf
  jmp alltraps
80107887:	e9 34 f9 ff ff       	jmp    801071c0 <alltraps>

8010788c <vector16>:
.globl vector16
vector16:
  pushl $0
8010788c:	6a 00                	push   $0x0
  pushl $16
8010788e:	6a 10                	push   $0x10
  jmp alltraps
80107890:	e9 2b f9 ff ff       	jmp    801071c0 <alltraps>

80107895 <vector17>:
.globl vector17
vector17:
  pushl $17
80107895:	6a 11                	push   $0x11
  jmp alltraps
80107897:	e9 24 f9 ff ff       	jmp    801071c0 <alltraps>

8010789c <vector18>:
.globl vector18
vector18:
  pushl $0
8010789c:	6a 00                	push   $0x0
  pushl $18
8010789e:	6a 12                	push   $0x12
  jmp alltraps
801078a0:	e9 1b f9 ff ff       	jmp    801071c0 <alltraps>

801078a5 <vector19>:
.globl vector19
vector19:
  pushl $0
801078a5:	6a 00                	push   $0x0
  pushl $19
801078a7:	6a 13                	push   $0x13
  jmp alltraps
801078a9:	e9 12 f9 ff ff       	jmp    801071c0 <alltraps>

801078ae <vector20>:
.globl vector20
vector20:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $20
801078b0:	6a 14                	push   $0x14
  jmp alltraps
801078b2:	e9 09 f9 ff ff       	jmp    801071c0 <alltraps>

801078b7 <vector21>:
.globl vector21
vector21:
  pushl $0
801078b7:	6a 00                	push   $0x0
  pushl $21
801078b9:	6a 15                	push   $0x15
  jmp alltraps
801078bb:	e9 00 f9 ff ff       	jmp    801071c0 <alltraps>

801078c0 <vector22>:
.globl vector22
vector22:
  pushl $0
801078c0:	6a 00                	push   $0x0
  pushl $22
801078c2:	6a 16                	push   $0x16
  jmp alltraps
801078c4:	e9 f7 f8 ff ff       	jmp    801071c0 <alltraps>

801078c9 <vector23>:
.globl vector23
vector23:
  pushl $0
801078c9:	6a 00                	push   $0x0
  pushl $23
801078cb:	6a 17                	push   $0x17
  jmp alltraps
801078cd:	e9 ee f8 ff ff       	jmp    801071c0 <alltraps>

801078d2 <vector24>:
.globl vector24
vector24:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $24
801078d4:	6a 18                	push   $0x18
  jmp alltraps
801078d6:	e9 e5 f8 ff ff       	jmp    801071c0 <alltraps>

801078db <vector25>:
.globl vector25
vector25:
  pushl $0
801078db:	6a 00                	push   $0x0
  pushl $25
801078dd:	6a 19                	push   $0x19
  jmp alltraps
801078df:	e9 dc f8 ff ff       	jmp    801071c0 <alltraps>

801078e4 <vector26>:
.globl vector26
vector26:
  pushl $0
801078e4:	6a 00                	push   $0x0
  pushl $26
801078e6:	6a 1a                	push   $0x1a
  jmp alltraps
801078e8:	e9 d3 f8 ff ff       	jmp    801071c0 <alltraps>

801078ed <vector27>:
.globl vector27
vector27:
  pushl $0
801078ed:	6a 00                	push   $0x0
  pushl $27
801078ef:	6a 1b                	push   $0x1b
  jmp alltraps
801078f1:	e9 ca f8 ff ff       	jmp    801071c0 <alltraps>

801078f6 <vector28>:
.globl vector28
vector28:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $28
801078f8:	6a 1c                	push   $0x1c
  jmp alltraps
801078fa:	e9 c1 f8 ff ff       	jmp    801071c0 <alltraps>

801078ff <vector29>:
.globl vector29
vector29:
  pushl $0
801078ff:	6a 00                	push   $0x0
  pushl $29
80107901:	6a 1d                	push   $0x1d
  jmp alltraps
80107903:	e9 b8 f8 ff ff       	jmp    801071c0 <alltraps>

80107908 <vector30>:
.globl vector30
vector30:
  pushl $0
80107908:	6a 00                	push   $0x0
  pushl $30
8010790a:	6a 1e                	push   $0x1e
  jmp alltraps
8010790c:	e9 af f8 ff ff       	jmp    801071c0 <alltraps>

80107911 <vector31>:
.globl vector31
vector31:
  pushl $0
80107911:	6a 00                	push   $0x0
  pushl $31
80107913:	6a 1f                	push   $0x1f
  jmp alltraps
80107915:	e9 a6 f8 ff ff       	jmp    801071c0 <alltraps>

8010791a <vector32>:
.globl vector32
vector32:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $32
8010791c:	6a 20                	push   $0x20
  jmp alltraps
8010791e:	e9 9d f8 ff ff       	jmp    801071c0 <alltraps>

80107923 <vector33>:
.globl vector33
vector33:
  pushl $0
80107923:	6a 00                	push   $0x0
  pushl $33
80107925:	6a 21                	push   $0x21
  jmp alltraps
80107927:	e9 94 f8 ff ff       	jmp    801071c0 <alltraps>

8010792c <vector34>:
.globl vector34
vector34:
  pushl $0
8010792c:	6a 00                	push   $0x0
  pushl $34
8010792e:	6a 22                	push   $0x22
  jmp alltraps
80107930:	e9 8b f8 ff ff       	jmp    801071c0 <alltraps>

80107935 <vector35>:
.globl vector35
vector35:
  pushl $0
80107935:	6a 00                	push   $0x0
  pushl $35
80107937:	6a 23                	push   $0x23
  jmp alltraps
80107939:	e9 82 f8 ff ff       	jmp    801071c0 <alltraps>

8010793e <vector36>:
.globl vector36
vector36:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $36
80107940:	6a 24                	push   $0x24
  jmp alltraps
80107942:	e9 79 f8 ff ff       	jmp    801071c0 <alltraps>

80107947 <vector37>:
.globl vector37
vector37:
  pushl $0
80107947:	6a 00                	push   $0x0
  pushl $37
80107949:	6a 25                	push   $0x25
  jmp alltraps
8010794b:	e9 70 f8 ff ff       	jmp    801071c0 <alltraps>

80107950 <vector38>:
.globl vector38
vector38:
  pushl $0
80107950:	6a 00                	push   $0x0
  pushl $38
80107952:	6a 26                	push   $0x26
  jmp alltraps
80107954:	e9 67 f8 ff ff       	jmp    801071c0 <alltraps>

80107959 <vector39>:
.globl vector39
vector39:
  pushl $0
80107959:	6a 00                	push   $0x0
  pushl $39
8010795b:	6a 27                	push   $0x27
  jmp alltraps
8010795d:	e9 5e f8 ff ff       	jmp    801071c0 <alltraps>

80107962 <vector40>:
.globl vector40
vector40:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $40
80107964:	6a 28                	push   $0x28
  jmp alltraps
80107966:	e9 55 f8 ff ff       	jmp    801071c0 <alltraps>

8010796b <vector41>:
.globl vector41
vector41:
  pushl $0
8010796b:	6a 00                	push   $0x0
  pushl $41
8010796d:	6a 29                	push   $0x29
  jmp alltraps
8010796f:	e9 4c f8 ff ff       	jmp    801071c0 <alltraps>

80107974 <vector42>:
.globl vector42
vector42:
  pushl $0
80107974:	6a 00                	push   $0x0
  pushl $42
80107976:	6a 2a                	push   $0x2a
  jmp alltraps
80107978:	e9 43 f8 ff ff       	jmp    801071c0 <alltraps>

8010797d <vector43>:
.globl vector43
vector43:
  pushl $0
8010797d:	6a 00                	push   $0x0
  pushl $43
8010797f:	6a 2b                	push   $0x2b
  jmp alltraps
80107981:	e9 3a f8 ff ff       	jmp    801071c0 <alltraps>

80107986 <vector44>:
.globl vector44
vector44:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $44
80107988:	6a 2c                	push   $0x2c
  jmp alltraps
8010798a:	e9 31 f8 ff ff       	jmp    801071c0 <alltraps>

8010798f <vector45>:
.globl vector45
vector45:
  pushl $0
8010798f:	6a 00                	push   $0x0
  pushl $45
80107991:	6a 2d                	push   $0x2d
  jmp alltraps
80107993:	e9 28 f8 ff ff       	jmp    801071c0 <alltraps>

80107998 <vector46>:
.globl vector46
vector46:
  pushl $0
80107998:	6a 00                	push   $0x0
  pushl $46
8010799a:	6a 2e                	push   $0x2e
  jmp alltraps
8010799c:	e9 1f f8 ff ff       	jmp    801071c0 <alltraps>

801079a1 <vector47>:
.globl vector47
vector47:
  pushl $0
801079a1:	6a 00                	push   $0x0
  pushl $47
801079a3:	6a 2f                	push   $0x2f
  jmp alltraps
801079a5:	e9 16 f8 ff ff       	jmp    801071c0 <alltraps>

801079aa <vector48>:
.globl vector48
vector48:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $48
801079ac:	6a 30                	push   $0x30
  jmp alltraps
801079ae:	e9 0d f8 ff ff       	jmp    801071c0 <alltraps>

801079b3 <vector49>:
.globl vector49
vector49:
  pushl $0
801079b3:	6a 00                	push   $0x0
  pushl $49
801079b5:	6a 31                	push   $0x31
  jmp alltraps
801079b7:	e9 04 f8 ff ff       	jmp    801071c0 <alltraps>

801079bc <vector50>:
.globl vector50
vector50:
  pushl $0
801079bc:	6a 00                	push   $0x0
  pushl $50
801079be:	6a 32                	push   $0x32
  jmp alltraps
801079c0:	e9 fb f7 ff ff       	jmp    801071c0 <alltraps>

801079c5 <vector51>:
.globl vector51
vector51:
  pushl $0
801079c5:	6a 00                	push   $0x0
  pushl $51
801079c7:	6a 33                	push   $0x33
  jmp alltraps
801079c9:	e9 f2 f7 ff ff       	jmp    801071c0 <alltraps>

801079ce <vector52>:
.globl vector52
vector52:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $52
801079d0:	6a 34                	push   $0x34
  jmp alltraps
801079d2:	e9 e9 f7 ff ff       	jmp    801071c0 <alltraps>

801079d7 <vector53>:
.globl vector53
vector53:
  pushl $0
801079d7:	6a 00                	push   $0x0
  pushl $53
801079d9:	6a 35                	push   $0x35
  jmp alltraps
801079db:	e9 e0 f7 ff ff       	jmp    801071c0 <alltraps>

801079e0 <vector54>:
.globl vector54
vector54:
  pushl $0
801079e0:	6a 00                	push   $0x0
  pushl $54
801079e2:	6a 36                	push   $0x36
  jmp alltraps
801079e4:	e9 d7 f7 ff ff       	jmp    801071c0 <alltraps>

801079e9 <vector55>:
.globl vector55
vector55:
  pushl $0
801079e9:	6a 00                	push   $0x0
  pushl $55
801079eb:	6a 37                	push   $0x37
  jmp alltraps
801079ed:	e9 ce f7 ff ff       	jmp    801071c0 <alltraps>

801079f2 <vector56>:
.globl vector56
vector56:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $56
801079f4:	6a 38                	push   $0x38
  jmp alltraps
801079f6:	e9 c5 f7 ff ff       	jmp    801071c0 <alltraps>

801079fb <vector57>:
.globl vector57
vector57:
  pushl $0
801079fb:	6a 00                	push   $0x0
  pushl $57
801079fd:	6a 39                	push   $0x39
  jmp alltraps
801079ff:	e9 bc f7 ff ff       	jmp    801071c0 <alltraps>

80107a04 <vector58>:
.globl vector58
vector58:
  pushl $0
80107a04:	6a 00                	push   $0x0
  pushl $58
80107a06:	6a 3a                	push   $0x3a
  jmp alltraps
80107a08:	e9 b3 f7 ff ff       	jmp    801071c0 <alltraps>

80107a0d <vector59>:
.globl vector59
vector59:
  pushl $0
80107a0d:	6a 00                	push   $0x0
  pushl $59
80107a0f:	6a 3b                	push   $0x3b
  jmp alltraps
80107a11:	e9 aa f7 ff ff       	jmp    801071c0 <alltraps>

80107a16 <vector60>:
.globl vector60
vector60:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $60
80107a18:	6a 3c                	push   $0x3c
  jmp alltraps
80107a1a:	e9 a1 f7 ff ff       	jmp    801071c0 <alltraps>

80107a1f <vector61>:
.globl vector61
vector61:
  pushl $0
80107a1f:	6a 00                	push   $0x0
  pushl $61
80107a21:	6a 3d                	push   $0x3d
  jmp alltraps
80107a23:	e9 98 f7 ff ff       	jmp    801071c0 <alltraps>

80107a28 <vector62>:
.globl vector62
vector62:
  pushl $0
80107a28:	6a 00                	push   $0x0
  pushl $62
80107a2a:	6a 3e                	push   $0x3e
  jmp alltraps
80107a2c:	e9 8f f7 ff ff       	jmp    801071c0 <alltraps>

80107a31 <vector63>:
.globl vector63
vector63:
  pushl $0
80107a31:	6a 00                	push   $0x0
  pushl $63
80107a33:	6a 3f                	push   $0x3f
  jmp alltraps
80107a35:	e9 86 f7 ff ff       	jmp    801071c0 <alltraps>

80107a3a <vector64>:
.globl vector64
vector64:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $64
80107a3c:	6a 40                	push   $0x40
  jmp alltraps
80107a3e:	e9 7d f7 ff ff       	jmp    801071c0 <alltraps>

80107a43 <vector65>:
.globl vector65
vector65:
  pushl $0
80107a43:	6a 00                	push   $0x0
  pushl $65
80107a45:	6a 41                	push   $0x41
  jmp alltraps
80107a47:	e9 74 f7 ff ff       	jmp    801071c0 <alltraps>

80107a4c <vector66>:
.globl vector66
vector66:
  pushl $0
80107a4c:	6a 00                	push   $0x0
  pushl $66
80107a4e:	6a 42                	push   $0x42
  jmp alltraps
80107a50:	e9 6b f7 ff ff       	jmp    801071c0 <alltraps>

80107a55 <vector67>:
.globl vector67
vector67:
  pushl $0
80107a55:	6a 00                	push   $0x0
  pushl $67
80107a57:	6a 43                	push   $0x43
  jmp alltraps
80107a59:	e9 62 f7 ff ff       	jmp    801071c0 <alltraps>

80107a5e <vector68>:
.globl vector68
vector68:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $68
80107a60:	6a 44                	push   $0x44
  jmp alltraps
80107a62:	e9 59 f7 ff ff       	jmp    801071c0 <alltraps>

80107a67 <vector69>:
.globl vector69
vector69:
  pushl $0
80107a67:	6a 00                	push   $0x0
  pushl $69
80107a69:	6a 45                	push   $0x45
  jmp alltraps
80107a6b:	e9 50 f7 ff ff       	jmp    801071c0 <alltraps>

80107a70 <vector70>:
.globl vector70
vector70:
  pushl $0
80107a70:	6a 00                	push   $0x0
  pushl $70
80107a72:	6a 46                	push   $0x46
  jmp alltraps
80107a74:	e9 47 f7 ff ff       	jmp    801071c0 <alltraps>

80107a79 <vector71>:
.globl vector71
vector71:
  pushl $0
80107a79:	6a 00                	push   $0x0
  pushl $71
80107a7b:	6a 47                	push   $0x47
  jmp alltraps
80107a7d:	e9 3e f7 ff ff       	jmp    801071c0 <alltraps>

80107a82 <vector72>:
.globl vector72
vector72:
  pushl $0
80107a82:	6a 00                	push   $0x0
  pushl $72
80107a84:	6a 48                	push   $0x48
  jmp alltraps
80107a86:	e9 35 f7 ff ff       	jmp    801071c0 <alltraps>

80107a8b <vector73>:
.globl vector73
vector73:
  pushl $0
80107a8b:	6a 00                	push   $0x0
  pushl $73
80107a8d:	6a 49                	push   $0x49
  jmp alltraps
80107a8f:	e9 2c f7 ff ff       	jmp    801071c0 <alltraps>

80107a94 <vector74>:
.globl vector74
vector74:
  pushl $0
80107a94:	6a 00                	push   $0x0
  pushl $74
80107a96:	6a 4a                	push   $0x4a
  jmp alltraps
80107a98:	e9 23 f7 ff ff       	jmp    801071c0 <alltraps>

80107a9d <vector75>:
.globl vector75
vector75:
  pushl $0
80107a9d:	6a 00                	push   $0x0
  pushl $75
80107a9f:	6a 4b                	push   $0x4b
  jmp alltraps
80107aa1:	e9 1a f7 ff ff       	jmp    801071c0 <alltraps>

80107aa6 <vector76>:
.globl vector76
vector76:
  pushl $0
80107aa6:	6a 00                	push   $0x0
  pushl $76
80107aa8:	6a 4c                	push   $0x4c
  jmp alltraps
80107aaa:	e9 11 f7 ff ff       	jmp    801071c0 <alltraps>

80107aaf <vector77>:
.globl vector77
vector77:
  pushl $0
80107aaf:	6a 00                	push   $0x0
  pushl $77
80107ab1:	6a 4d                	push   $0x4d
  jmp alltraps
80107ab3:	e9 08 f7 ff ff       	jmp    801071c0 <alltraps>

80107ab8 <vector78>:
.globl vector78
vector78:
  pushl $0
80107ab8:	6a 00                	push   $0x0
  pushl $78
80107aba:	6a 4e                	push   $0x4e
  jmp alltraps
80107abc:	e9 ff f6 ff ff       	jmp    801071c0 <alltraps>

80107ac1 <vector79>:
.globl vector79
vector79:
  pushl $0
80107ac1:	6a 00                	push   $0x0
  pushl $79
80107ac3:	6a 4f                	push   $0x4f
  jmp alltraps
80107ac5:	e9 f6 f6 ff ff       	jmp    801071c0 <alltraps>

80107aca <vector80>:
.globl vector80
vector80:
  pushl $0
80107aca:	6a 00                	push   $0x0
  pushl $80
80107acc:	6a 50                	push   $0x50
  jmp alltraps
80107ace:	e9 ed f6 ff ff       	jmp    801071c0 <alltraps>

80107ad3 <vector81>:
.globl vector81
vector81:
  pushl $0
80107ad3:	6a 00                	push   $0x0
  pushl $81
80107ad5:	6a 51                	push   $0x51
  jmp alltraps
80107ad7:	e9 e4 f6 ff ff       	jmp    801071c0 <alltraps>

80107adc <vector82>:
.globl vector82
vector82:
  pushl $0
80107adc:	6a 00                	push   $0x0
  pushl $82
80107ade:	6a 52                	push   $0x52
  jmp alltraps
80107ae0:	e9 db f6 ff ff       	jmp    801071c0 <alltraps>

80107ae5 <vector83>:
.globl vector83
vector83:
  pushl $0
80107ae5:	6a 00                	push   $0x0
  pushl $83
80107ae7:	6a 53                	push   $0x53
  jmp alltraps
80107ae9:	e9 d2 f6 ff ff       	jmp    801071c0 <alltraps>

80107aee <vector84>:
.globl vector84
vector84:
  pushl $0
80107aee:	6a 00                	push   $0x0
  pushl $84
80107af0:	6a 54                	push   $0x54
  jmp alltraps
80107af2:	e9 c9 f6 ff ff       	jmp    801071c0 <alltraps>

80107af7 <vector85>:
.globl vector85
vector85:
  pushl $0
80107af7:	6a 00                	push   $0x0
  pushl $85
80107af9:	6a 55                	push   $0x55
  jmp alltraps
80107afb:	e9 c0 f6 ff ff       	jmp    801071c0 <alltraps>

80107b00 <vector86>:
.globl vector86
vector86:
  pushl $0
80107b00:	6a 00                	push   $0x0
  pushl $86
80107b02:	6a 56                	push   $0x56
  jmp alltraps
80107b04:	e9 b7 f6 ff ff       	jmp    801071c0 <alltraps>

80107b09 <vector87>:
.globl vector87
vector87:
  pushl $0
80107b09:	6a 00                	push   $0x0
  pushl $87
80107b0b:	6a 57                	push   $0x57
  jmp alltraps
80107b0d:	e9 ae f6 ff ff       	jmp    801071c0 <alltraps>

80107b12 <vector88>:
.globl vector88
vector88:
  pushl $0
80107b12:	6a 00                	push   $0x0
  pushl $88
80107b14:	6a 58                	push   $0x58
  jmp alltraps
80107b16:	e9 a5 f6 ff ff       	jmp    801071c0 <alltraps>

80107b1b <vector89>:
.globl vector89
vector89:
  pushl $0
80107b1b:	6a 00                	push   $0x0
  pushl $89
80107b1d:	6a 59                	push   $0x59
  jmp alltraps
80107b1f:	e9 9c f6 ff ff       	jmp    801071c0 <alltraps>

80107b24 <vector90>:
.globl vector90
vector90:
  pushl $0
80107b24:	6a 00                	push   $0x0
  pushl $90
80107b26:	6a 5a                	push   $0x5a
  jmp alltraps
80107b28:	e9 93 f6 ff ff       	jmp    801071c0 <alltraps>

80107b2d <vector91>:
.globl vector91
vector91:
  pushl $0
80107b2d:	6a 00                	push   $0x0
  pushl $91
80107b2f:	6a 5b                	push   $0x5b
  jmp alltraps
80107b31:	e9 8a f6 ff ff       	jmp    801071c0 <alltraps>

80107b36 <vector92>:
.globl vector92
vector92:
  pushl $0
80107b36:	6a 00                	push   $0x0
  pushl $92
80107b38:	6a 5c                	push   $0x5c
  jmp alltraps
80107b3a:	e9 81 f6 ff ff       	jmp    801071c0 <alltraps>

80107b3f <vector93>:
.globl vector93
vector93:
  pushl $0
80107b3f:	6a 00                	push   $0x0
  pushl $93
80107b41:	6a 5d                	push   $0x5d
  jmp alltraps
80107b43:	e9 78 f6 ff ff       	jmp    801071c0 <alltraps>

80107b48 <vector94>:
.globl vector94
vector94:
  pushl $0
80107b48:	6a 00                	push   $0x0
  pushl $94
80107b4a:	6a 5e                	push   $0x5e
  jmp alltraps
80107b4c:	e9 6f f6 ff ff       	jmp    801071c0 <alltraps>

80107b51 <vector95>:
.globl vector95
vector95:
  pushl $0
80107b51:	6a 00                	push   $0x0
  pushl $95
80107b53:	6a 5f                	push   $0x5f
  jmp alltraps
80107b55:	e9 66 f6 ff ff       	jmp    801071c0 <alltraps>

80107b5a <vector96>:
.globl vector96
vector96:
  pushl $0
80107b5a:	6a 00                	push   $0x0
  pushl $96
80107b5c:	6a 60                	push   $0x60
  jmp alltraps
80107b5e:	e9 5d f6 ff ff       	jmp    801071c0 <alltraps>

80107b63 <vector97>:
.globl vector97
vector97:
  pushl $0
80107b63:	6a 00                	push   $0x0
  pushl $97
80107b65:	6a 61                	push   $0x61
  jmp alltraps
80107b67:	e9 54 f6 ff ff       	jmp    801071c0 <alltraps>

80107b6c <vector98>:
.globl vector98
vector98:
  pushl $0
80107b6c:	6a 00                	push   $0x0
  pushl $98
80107b6e:	6a 62                	push   $0x62
  jmp alltraps
80107b70:	e9 4b f6 ff ff       	jmp    801071c0 <alltraps>

80107b75 <vector99>:
.globl vector99
vector99:
  pushl $0
80107b75:	6a 00                	push   $0x0
  pushl $99
80107b77:	6a 63                	push   $0x63
  jmp alltraps
80107b79:	e9 42 f6 ff ff       	jmp    801071c0 <alltraps>

80107b7e <vector100>:
.globl vector100
vector100:
  pushl $0
80107b7e:	6a 00                	push   $0x0
  pushl $100
80107b80:	6a 64                	push   $0x64
  jmp alltraps
80107b82:	e9 39 f6 ff ff       	jmp    801071c0 <alltraps>

80107b87 <vector101>:
.globl vector101
vector101:
  pushl $0
80107b87:	6a 00                	push   $0x0
  pushl $101
80107b89:	6a 65                	push   $0x65
  jmp alltraps
80107b8b:	e9 30 f6 ff ff       	jmp    801071c0 <alltraps>

80107b90 <vector102>:
.globl vector102
vector102:
  pushl $0
80107b90:	6a 00                	push   $0x0
  pushl $102
80107b92:	6a 66                	push   $0x66
  jmp alltraps
80107b94:	e9 27 f6 ff ff       	jmp    801071c0 <alltraps>

80107b99 <vector103>:
.globl vector103
vector103:
  pushl $0
80107b99:	6a 00                	push   $0x0
  pushl $103
80107b9b:	6a 67                	push   $0x67
  jmp alltraps
80107b9d:	e9 1e f6 ff ff       	jmp    801071c0 <alltraps>

80107ba2 <vector104>:
.globl vector104
vector104:
  pushl $0
80107ba2:	6a 00                	push   $0x0
  pushl $104
80107ba4:	6a 68                	push   $0x68
  jmp alltraps
80107ba6:	e9 15 f6 ff ff       	jmp    801071c0 <alltraps>

80107bab <vector105>:
.globl vector105
vector105:
  pushl $0
80107bab:	6a 00                	push   $0x0
  pushl $105
80107bad:	6a 69                	push   $0x69
  jmp alltraps
80107baf:	e9 0c f6 ff ff       	jmp    801071c0 <alltraps>

80107bb4 <vector106>:
.globl vector106
vector106:
  pushl $0
80107bb4:	6a 00                	push   $0x0
  pushl $106
80107bb6:	6a 6a                	push   $0x6a
  jmp alltraps
80107bb8:	e9 03 f6 ff ff       	jmp    801071c0 <alltraps>

80107bbd <vector107>:
.globl vector107
vector107:
  pushl $0
80107bbd:	6a 00                	push   $0x0
  pushl $107
80107bbf:	6a 6b                	push   $0x6b
  jmp alltraps
80107bc1:	e9 fa f5 ff ff       	jmp    801071c0 <alltraps>

80107bc6 <vector108>:
.globl vector108
vector108:
  pushl $0
80107bc6:	6a 00                	push   $0x0
  pushl $108
80107bc8:	6a 6c                	push   $0x6c
  jmp alltraps
80107bca:	e9 f1 f5 ff ff       	jmp    801071c0 <alltraps>

80107bcf <vector109>:
.globl vector109
vector109:
  pushl $0
80107bcf:	6a 00                	push   $0x0
  pushl $109
80107bd1:	6a 6d                	push   $0x6d
  jmp alltraps
80107bd3:	e9 e8 f5 ff ff       	jmp    801071c0 <alltraps>

80107bd8 <vector110>:
.globl vector110
vector110:
  pushl $0
80107bd8:	6a 00                	push   $0x0
  pushl $110
80107bda:	6a 6e                	push   $0x6e
  jmp alltraps
80107bdc:	e9 df f5 ff ff       	jmp    801071c0 <alltraps>

80107be1 <vector111>:
.globl vector111
vector111:
  pushl $0
80107be1:	6a 00                	push   $0x0
  pushl $111
80107be3:	6a 6f                	push   $0x6f
  jmp alltraps
80107be5:	e9 d6 f5 ff ff       	jmp    801071c0 <alltraps>

80107bea <vector112>:
.globl vector112
vector112:
  pushl $0
80107bea:	6a 00                	push   $0x0
  pushl $112
80107bec:	6a 70                	push   $0x70
  jmp alltraps
80107bee:	e9 cd f5 ff ff       	jmp    801071c0 <alltraps>

80107bf3 <vector113>:
.globl vector113
vector113:
  pushl $0
80107bf3:	6a 00                	push   $0x0
  pushl $113
80107bf5:	6a 71                	push   $0x71
  jmp alltraps
80107bf7:	e9 c4 f5 ff ff       	jmp    801071c0 <alltraps>

80107bfc <vector114>:
.globl vector114
vector114:
  pushl $0
80107bfc:	6a 00                	push   $0x0
  pushl $114
80107bfe:	6a 72                	push   $0x72
  jmp alltraps
80107c00:	e9 bb f5 ff ff       	jmp    801071c0 <alltraps>

80107c05 <vector115>:
.globl vector115
vector115:
  pushl $0
80107c05:	6a 00                	push   $0x0
  pushl $115
80107c07:	6a 73                	push   $0x73
  jmp alltraps
80107c09:	e9 b2 f5 ff ff       	jmp    801071c0 <alltraps>

80107c0e <vector116>:
.globl vector116
vector116:
  pushl $0
80107c0e:	6a 00                	push   $0x0
  pushl $116
80107c10:	6a 74                	push   $0x74
  jmp alltraps
80107c12:	e9 a9 f5 ff ff       	jmp    801071c0 <alltraps>

80107c17 <vector117>:
.globl vector117
vector117:
  pushl $0
80107c17:	6a 00                	push   $0x0
  pushl $117
80107c19:	6a 75                	push   $0x75
  jmp alltraps
80107c1b:	e9 a0 f5 ff ff       	jmp    801071c0 <alltraps>

80107c20 <vector118>:
.globl vector118
vector118:
  pushl $0
80107c20:	6a 00                	push   $0x0
  pushl $118
80107c22:	6a 76                	push   $0x76
  jmp alltraps
80107c24:	e9 97 f5 ff ff       	jmp    801071c0 <alltraps>

80107c29 <vector119>:
.globl vector119
vector119:
  pushl $0
80107c29:	6a 00                	push   $0x0
  pushl $119
80107c2b:	6a 77                	push   $0x77
  jmp alltraps
80107c2d:	e9 8e f5 ff ff       	jmp    801071c0 <alltraps>

80107c32 <vector120>:
.globl vector120
vector120:
  pushl $0
80107c32:	6a 00                	push   $0x0
  pushl $120
80107c34:	6a 78                	push   $0x78
  jmp alltraps
80107c36:	e9 85 f5 ff ff       	jmp    801071c0 <alltraps>

80107c3b <vector121>:
.globl vector121
vector121:
  pushl $0
80107c3b:	6a 00                	push   $0x0
  pushl $121
80107c3d:	6a 79                	push   $0x79
  jmp alltraps
80107c3f:	e9 7c f5 ff ff       	jmp    801071c0 <alltraps>

80107c44 <vector122>:
.globl vector122
vector122:
  pushl $0
80107c44:	6a 00                	push   $0x0
  pushl $122
80107c46:	6a 7a                	push   $0x7a
  jmp alltraps
80107c48:	e9 73 f5 ff ff       	jmp    801071c0 <alltraps>

80107c4d <vector123>:
.globl vector123
vector123:
  pushl $0
80107c4d:	6a 00                	push   $0x0
  pushl $123
80107c4f:	6a 7b                	push   $0x7b
  jmp alltraps
80107c51:	e9 6a f5 ff ff       	jmp    801071c0 <alltraps>

80107c56 <vector124>:
.globl vector124
vector124:
  pushl $0
80107c56:	6a 00                	push   $0x0
  pushl $124
80107c58:	6a 7c                	push   $0x7c
  jmp alltraps
80107c5a:	e9 61 f5 ff ff       	jmp    801071c0 <alltraps>

80107c5f <vector125>:
.globl vector125
vector125:
  pushl $0
80107c5f:	6a 00                	push   $0x0
  pushl $125
80107c61:	6a 7d                	push   $0x7d
  jmp alltraps
80107c63:	e9 58 f5 ff ff       	jmp    801071c0 <alltraps>

80107c68 <vector126>:
.globl vector126
vector126:
  pushl $0
80107c68:	6a 00                	push   $0x0
  pushl $126
80107c6a:	6a 7e                	push   $0x7e
  jmp alltraps
80107c6c:	e9 4f f5 ff ff       	jmp    801071c0 <alltraps>

80107c71 <vector127>:
.globl vector127
vector127:
  pushl $0
80107c71:	6a 00                	push   $0x0
  pushl $127
80107c73:	6a 7f                	push   $0x7f
  jmp alltraps
80107c75:	e9 46 f5 ff ff       	jmp    801071c0 <alltraps>

80107c7a <vector128>:
.globl vector128
vector128:
  pushl $0
80107c7a:	6a 00                	push   $0x0
  pushl $128
80107c7c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107c81:	e9 3a f5 ff ff       	jmp    801071c0 <alltraps>

80107c86 <vector129>:
.globl vector129
vector129:
  pushl $0
80107c86:	6a 00                	push   $0x0
  pushl $129
80107c88:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107c8d:	e9 2e f5 ff ff       	jmp    801071c0 <alltraps>

80107c92 <vector130>:
.globl vector130
vector130:
  pushl $0
80107c92:	6a 00                	push   $0x0
  pushl $130
80107c94:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107c99:	e9 22 f5 ff ff       	jmp    801071c0 <alltraps>

80107c9e <vector131>:
.globl vector131
vector131:
  pushl $0
80107c9e:	6a 00                	push   $0x0
  pushl $131
80107ca0:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107ca5:	e9 16 f5 ff ff       	jmp    801071c0 <alltraps>

80107caa <vector132>:
.globl vector132
vector132:
  pushl $0
80107caa:	6a 00                	push   $0x0
  pushl $132
80107cac:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107cb1:	e9 0a f5 ff ff       	jmp    801071c0 <alltraps>

80107cb6 <vector133>:
.globl vector133
vector133:
  pushl $0
80107cb6:	6a 00                	push   $0x0
  pushl $133
80107cb8:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107cbd:	e9 fe f4 ff ff       	jmp    801071c0 <alltraps>

80107cc2 <vector134>:
.globl vector134
vector134:
  pushl $0
80107cc2:	6a 00                	push   $0x0
  pushl $134
80107cc4:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107cc9:	e9 f2 f4 ff ff       	jmp    801071c0 <alltraps>

80107cce <vector135>:
.globl vector135
vector135:
  pushl $0
80107cce:	6a 00                	push   $0x0
  pushl $135
80107cd0:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107cd5:	e9 e6 f4 ff ff       	jmp    801071c0 <alltraps>

80107cda <vector136>:
.globl vector136
vector136:
  pushl $0
80107cda:	6a 00                	push   $0x0
  pushl $136
80107cdc:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107ce1:	e9 da f4 ff ff       	jmp    801071c0 <alltraps>

80107ce6 <vector137>:
.globl vector137
vector137:
  pushl $0
80107ce6:	6a 00                	push   $0x0
  pushl $137
80107ce8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107ced:	e9 ce f4 ff ff       	jmp    801071c0 <alltraps>

80107cf2 <vector138>:
.globl vector138
vector138:
  pushl $0
80107cf2:	6a 00                	push   $0x0
  pushl $138
80107cf4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107cf9:	e9 c2 f4 ff ff       	jmp    801071c0 <alltraps>

80107cfe <vector139>:
.globl vector139
vector139:
  pushl $0
80107cfe:	6a 00                	push   $0x0
  pushl $139
80107d00:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107d05:	e9 b6 f4 ff ff       	jmp    801071c0 <alltraps>

80107d0a <vector140>:
.globl vector140
vector140:
  pushl $0
80107d0a:	6a 00                	push   $0x0
  pushl $140
80107d0c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107d11:	e9 aa f4 ff ff       	jmp    801071c0 <alltraps>

80107d16 <vector141>:
.globl vector141
vector141:
  pushl $0
80107d16:	6a 00                	push   $0x0
  pushl $141
80107d18:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107d1d:	e9 9e f4 ff ff       	jmp    801071c0 <alltraps>

80107d22 <vector142>:
.globl vector142
vector142:
  pushl $0
80107d22:	6a 00                	push   $0x0
  pushl $142
80107d24:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107d29:	e9 92 f4 ff ff       	jmp    801071c0 <alltraps>

80107d2e <vector143>:
.globl vector143
vector143:
  pushl $0
80107d2e:	6a 00                	push   $0x0
  pushl $143
80107d30:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107d35:	e9 86 f4 ff ff       	jmp    801071c0 <alltraps>

80107d3a <vector144>:
.globl vector144
vector144:
  pushl $0
80107d3a:	6a 00                	push   $0x0
  pushl $144
80107d3c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107d41:	e9 7a f4 ff ff       	jmp    801071c0 <alltraps>

80107d46 <vector145>:
.globl vector145
vector145:
  pushl $0
80107d46:	6a 00                	push   $0x0
  pushl $145
80107d48:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107d4d:	e9 6e f4 ff ff       	jmp    801071c0 <alltraps>

80107d52 <vector146>:
.globl vector146
vector146:
  pushl $0
80107d52:	6a 00                	push   $0x0
  pushl $146
80107d54:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107d59:	e9 62 f4 ff ff       	jmp    801071c0 <alltraps>

80107d5e <vector147>:
.globl vector147
vector147:
  pushl $0
80107d5e:	6a 00                	push   $0x0
  pushl $147
80107d60:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107d65:	e9 56 f4 ff ff       	jmp    801071c0 <alltraps>

80107d6a <vector148>:
.globl vector148
vector148:
  pushl $0
80107d6a:	6a 00                	push   $0x0
  pushl $148
80107d6c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107d71:	e9 4a f4 ff ff       	jmp    801071c0 <alltraps>

80107d76 <vector149>:
.globl vector149
vector149:
  pushl $0
80107d76:	6a 00                	push   $0x0
  pushl $149
80107d78:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107d7d:	e9 3e f4 ff ff       	jmp    801071c0 <alltraps>

80107d82 <vector150>:
.globl vector150
vector150:
  pushl $0
80107d82:	6a 00                	push   $0x0
  pushl $150
80107d84:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107d89:	e9 32 f4 ff ff       	jmp    801071c0 <alltraps>

80107d8e <vector151>:
.globl vector151
vector151:
  pushl $0
80107d8e:	6a 00                	push   $0x0
  pushl $151
80107d90:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107d95:	e9 26 f4 ff ff       	jmp    801071c0 <alltraps>

80107d9a <vector152>:
.globl vector152
vector152:
  pushl $0
80107d9a:	6a 00                	push   $0x0
  pushl $152
80107d9c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107da1:	e9 1a f4 ff ff       	jmp    801071c0 <alltraps>

80107da6 <vector153>:
.globl vector153
vector153:
  pushl $0
80107da6:	6a 00                	push   $0x0
  pushl $153
80107da8:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107dad:	e9 0e f4 ff ff       	jmp    801071c0 <alltraps>

80107db2 <vector154>:
.globl vector154
vector154:
  pushl $0
80107db2:	6a 00                	push   $0x0
  pushl $154
80107db4:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107db9:	e9 02 f4 ff ff       	jmp    801071c0 <alltraps>

80107dbe <vector155>:
.globl vector155
vector155:
  pushl $0
80107dbe:	6a 00                	push   $0x0
  pushl $155
80107dc0:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107dc5:	e9 f6 f3 ff ff       	jmp    801071c0 <alltraps>

80107dca <vector156>:
.globl vector156
vector156:
  pushl $0
80107dca:	6a 00                	push   $0x0
  pushl $156
80107dcc:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107dd1:	e9 ea f3 ff ff       	jmp    801071c0 <alltraps>

80107dd6 <vector157>:
.globl vector157
vector157:
  pushl $0
80107dd6:	6a 00                	push   $0x0
  pushl $157
80107dd8:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107ddd:	e9 de f3 ff ff       	jmp    801071c0 <alltraps>

80107de2 <vector158>:
.globl vector158
vector158:
  pushl $0
80107de2:	6a 00                	push   $0x0
  pushl $158
80107de4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107de9:	e9 d2 f3 ff ff       	jmp    801071c0 <alltraps>

80107dee <vector159>:
.globl vector159
vector159:
  pushl $0
80107dee:	6a 00                	push   $0x0
  pushl $159
80107df0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107df5:	e9 c6 f3 ff ff       	jmp    801071c0 <alltraps>

80107dfa <vector160>:
.globl vector160
vector160:
  pushl $0
80107dfa:	6a 00                	push   $0x0
  pushl $160
80107dfc:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107e01:	e9 ba f3 ff ff       	jmp    801071c0 <alltraps>

80107e06 <vector161>:
.globl vector161
vector161:
  pushl $0
80107e06:	6a 00                	push   $0x0
  pushl $161
80107e08:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107e0d:	e9 ae f3 ff ff       	jmp    801071c0 <alltraps>

80107e12 <vector162>:
.globl vector162
vector162:
  pushl $0
80107e12:	6a 00                	push   $0x0
  pushl $162
80107e14:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107e19:	e9 a2 f3 ff ff       	jmp    801071c0 <alltraps>

80107e1e <vector163>:
.globl vector163
vector163:
  pushl $0
80107e1e:	6a 00                	push   $0x0
  pushl $163
80107e20:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107e25:	e9 96 f3 ff ff       	jmp    801071c0 <alltraps>

80107e2a <vector164>:
.globl vector164
vector164:
  pushl $0
80107e2a:	6a 00                	push   $0x0
  pushl $164
80107e2c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107e31:	e9 8a f3 ff ff       	jmp    801071c0 <alltraps>

80107e36 <vector165>:
.globl vector165
vector165:
  pushl $0
80107e36:	6a 00                	push   $0x0
  pushl $165
80107e38:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107e3d:	e9 7e f3 ff ff       	jmp    801071c0 <alltraps>

80107e42 <vector166>:
.globl vector166
vector166:
  pushl $0
80107e42:	6a 00                	push   $0x0
  pushl $166
80107e44:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107e49:	e9 72 f3 ff ff       	jmp    801071c0 <alltraps>

80107e4e <vector167>:
.globl vector167
vector167:
  pushl $0
80107e4e:	6a 00                	push   $0x0
  pushl $167
80107e50:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107e55:	e9 66 f3 ff ff       	jmp    801071c0 <alltraps>

80107e5a <vector168>:
.globl vector168
vector168:
  pushl $0
80107e5a:	6a 00                	push   $0x0
  pushl $168
80107e5c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107e61:	e9 5a f3 ff ff       	jmp    801071c0 <alltraps>

80107e66 <vector169>:
.globl vector169
vector169:
  pushl $0
80107e66:	6a 00                	push   $0x0
  pushl $169
80107e68:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107e6d:	e9 4e f3 ff ff       	jmp    801071c0 <alltraps>

80107e72 <vector170>:
.globl vector170
vector170:
  pushl $0
80107e72:	6a 00                	push   $0x0
  pushl $170
80107e74:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107e79:	e9 42 f3 ff ff       	jmp    801071c0 <alltraps>

80107e7e <vector171>:
.globl vector171
vector171:
  pushl $0
80107e7e:	6a 00                	push   $0x0
  pushl $171
80107e80:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107e85:	e9 36 f3 ff ff       	jmp    801071c0 <alltraps>

80107e8a <vector172>:
.globl vector172
vector172:
  pushl $0
80107e8a:	6a 00                	push   $0x0
  pushl $172
80107e8c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107e91:	e9 2a f3 ff ff       	jmp    801071c0 <alltraps>

80107e96 <vector173>:
.globl vector173
vector173:
  pushl $0
80107e96:	6a 00                	push   $0x0
  pushl $173
80107e98:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107e9d:	e9 1e f3 ff ff       	jmp    801071c0 <alltraps>

80107ea2 <vector174>:
.globl vector174
vector174:
  pushl $0
80107ea2:	6a 00                	push   $0x0
  pushl $174
80107ea4:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107ea9:	e9 12 f3 ff ff       	jmp    801071c0 <alltraps>

80107eae <vector175>:
.globl vector175
vector175:
  pushl $0
80107eae:	6a 00                	push   $0x0
  pushl $175
80107eb0:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107eb5:	e9 06 f3 ff ff       	jmp    801071c0 <alltraps>

80107eba <vector176>:
.globl vector176
vector176:
  pushl $0
80107eba:	6a 00                	push   $0x0
  pushl $176
80107ebc:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107ec1:	e9 fa f2 ff ff       	jmp    801071c0 <alltraps>

80107ec6 <vector177>:
.globl vector177
vector177:
  pushl $0
80107ec6:	6a 00                	push   $0x0
  pushl $177
80107ec8:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107ecd:	e9 ee f2 ff ff       	jmp    801071c0 <alltraps>

80107ed2 <vector178>:
.globl vector178
vector178:
  pushl $0
80107ed2:	6a 00                	push   $0x0
  pushl $178
80107ed4:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107ed9:	e9 e2 f2 ff ff       	jmp    801071c0 <alltraps>

80107ede <vector179>:
.globl vector179
vector179:
  pushl $0
80107ede:	6a 00                	push   $0x0
  pushl $179
80107ee0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107ee5:	e9 d6 f2 ff ff       	jmp    801071c0 <alltraps>

80107eea <vector180>:
.globl vector180
vector180:
  pushl $0
80107eea:	6a 00                	push   $0x0
  pushl $180
80107eec:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107ef1:	e9 ca f2 ff ff       	jmp    801071c0 <alltraps>

80107ef6 <vector181>:
.globl vector181
vector181:
  pushl $0
80107ef6:	6a 00                	push   $0x0
  pushl $181
80107ef8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107efd:	e9 be f2 ff ff       	jmp    801071c0 <alltraps>

80107f02 <vector182>:
.globl vector182
vector182:
  pushl $0
80107f02:	6a 00                	push   $0x0
  pushl $182
80107f04:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107f09:	e9 b2 f2 ff ff       	jmp    801071c0 <alltraps>

80107f0e <vector183>:
.globl vector183
vector183:
  pushl $0
80107f0e:	6a 00                	push   $0x0
  pushl $183
80107f10:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107f15:	e9 a6 f2 ff ff       	jmp    801071c0 <alltraps>

80107f1a <vector184>:
.globl vector184
vector184:
  pushl $0
80107f1a:	6a 00                	push   $0x0
  pushl $184
80107f1c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107f21:	e9 9a f2 ff ff       	jmp    801071c0 <alltraps>

80107f26 <vector185>:
.globl vector185
vector185:
  pushl $0
80107f26:	6a 00                	push   $0x0
  pushl $185
80107f28:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107f2d:	e9 8e f2 ff ff       	jmp    801071c0 <alltraps>

80107f32 <vector186>:
.globl vector186
vector186:
  pushl $0
80107f32:	6a 00                	push   $0x0
  pushl $186
80107f34:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107f39:	e9 82 f2 ff ff       	jmp    801071c0 <alltraps>

80107f3e <vector187>:
.globl vector187
vector187:
  pushl $0
80107f3e:	6a 00                	push   $0x0
  pushl $187
80107f40:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107f45:	e9 76 f2 ff ff       	jmp    801071c0 <alltraps>

80107f4a <vector188>:
.globl vector188
vector188:
  pushl $0
80107f4a:	6a 00                	push   $0x0
  pushl $188
80107f4c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107f51:	e9 6a f2 ff ff       	jmp    801071c0 <alltraps>

80107f56 <vector189>:
.globl vector189
vector189:
  pushl $0
80107f56:	6a 00                	push   $0x0
  pushl $189
80107f58:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107f5d:	e9 5e f2 ff ff       	jmp    801071c0 <alltraps>

80107f62 <vector190>:
.globl vector190
vector190:
  pushl $0
80107f62:	6a 00                	push   $0x0
  pushl $190
80107f64:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107f69:	e9 52 f2 ff ff       	jmp    801071c0 <alltraps>

80107f6e <vector191>:
.globl vector191
vector191:
  pushl $0
80107f6e:	6a 00                	push   $0x0
  pushl $191
80107f70:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107f75:	e9 46 f2 ff ff       	jmp    801071c0 <alltraps>

80107f7a <vector192>:
.globl vector192
vector192:
  pushl $0
80107f7a:	6a 00                	push   $0x0
  pushl $192
80107f7c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107f81:	e9 3a f2 ff ff       	jmp    801071c0 <alltraps>

80107f86 <vector193>:
.globl vector193
vector193:
  pushl $0
80107f86:	6a 00                	push   $0x0
  pushl $193
80107f88:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107f8d:	e9 2e f2 ff ff       	jmp    801071c0 <alltraps>

80107f92 <vector194>:
.globl vector194
vector194:
  pushl $0
80107f92:	6a 00                	push   $0x0
  pushl $194
80107f94:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107f99:	e9 22 f2 ff ff       	jmp    801071c0 <alltraps>

80107f9e <vector195>:
.globl vector195
vector195:
  pushl $0
80107f9e:	6a 00                	push   $0x0
  pushl $195
80107fa0:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107fa5:	e9 16 f2 ff ff       	jmp    801071c0 <alltraps>

80107faa <vector196>:
.globl vector196
vector196:
  pushl $0
80107faa:	6a 00                	push   $0x0
  pushl $196
80107fac:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107fb1:	e9 0a f2 ff ff       	jmp    801071c0 <alltraps>

80107fb6 <vector197>:
.globl vector197
vector197:
  pushl $0
80107fb6:	6a 00                	push   $0x0
  pushl $197
80107fb8:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107fbd:	e9 fe f1 ff ff       	jmp    801071c0 <alltraps>

80107fc2 <vector198>:
.globl vector198
vector198:
  pushl $0
80107fc2:	6a 00                	push   $0x0
  pushl $198
80107fc4:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107fc9:	e9 f2 f1 ff ff       	jmp    801071c0 <alltraps>

80107fce <vector199>:
.globl vector199
vector199:
  pushl $0
80107fce:	6a 00                	push   $0x0
  pushl $199
80107fd0:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107fd5:	e9 e6 f1 ff ff       	jmp    801071c0 <alltraps>

80107fda <vector200>:
.globl vector200
vector200:
  pushl $0
80107fda:	6a 00                	push   $0x0
  pushl $200
80107fdc:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107fe1:	e9 da f1 ff ff       	jmp    801071c0 <alltraps>

80107fe6 <vector201>:
.globl vector201
vector201:
  pushl $0
80107fe6:	6a 00                	push   $0x0
  pushl $201
80107fe8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107fed:	e9 ce f1 ff ff       	jmp    801071c0 <alltraps>

80107ff2 <vector202>:
.globl vector202
vector202:
  pushl $0
80107ff2:	6a 00                	push   $0x0
  pushl $202
80107ff4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107ff9:	e9 c2 f1 ff ff       	jmp    801071c0 <alltraps>

80107ffe <vector203>:
.globl vector203
vector203:
  pushl $0
80107ffe:	6a 00                	push   $0x0
  pushl $203
80108000:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108005:	e9 b6 f1 ff ff       	jmp    801071c0 <alltraps>

8010800a <vector204>:
.globl vector204
vector204:
  pushl $0
8010800a:	6a 00                	push   $0x0
  pushl $204
8010800c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108011:	e9 aa f1 ff ff       	jmp    801071c0 <alltraps>

80108016 <vector205>:
.globl vector205
vector205:
  pushl $0
80108016:	6a 00                	push   $0x0
  pushl $205
80108018:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010801d:	e9 9e f1 ff ff       	jmp    801071c0 <alltraps>

80108022 <vector206>:
.globl vector206
vector206:
  pushl $0
80108022:	6a 00                	push   $0x0
  pushl $206
80108024:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108029:	e9 92 f1 ff ff       	jmp    801071c0 <alltraps>

8010802e <vector207>:
.globl vector207
vector207:
  pushl $0
8010802e:	6a 00                	push   $0x0
  pushl $207
80108030:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108035:	e9 86 f1 ff ff       	jmp    801071c0 <alltraps>

8010803a <vector208>:
.globl vector208
vector208:
  pushl $0
8010803a:	6a 00                	push   $0x0
  pushl $208
8010803c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108041:	e9 7a f1 ff ff       	jmp    801071c0 <alltraps>

80108046 <vector209>:
.globl vector209
vector209:
  pushl $0
80108046:	6a 00                	push   $0x0
  pushl $209
80108048:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010804d:	e9 6e f1 ff ff       	jmp    801071c0 <alltraps>

80108052 <vector210>:
.globl vector210
vector210:
  pushl $0
80108052:	6a 00                	push   $0x0
  pushl $210
80108054:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108059:	e9 62 f1 ff ff       	jmp    801071c0 <alltraps>

8010805e <vector211>:
.globl vector211
vector211:
  pushl $0
8010805e:	6a 00                	push   $0x0
  pushl $211
80108060:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108065:	e9 56 f1 ff ff       	jmp    801071c0 <alltraps>

8010806a <vector212>:
.globl vector212
vector212:
  pushl $0
8010806a:	6a 00                	push   $0x0
  pushl $212
8010806c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108071:	e9 4a f1 ff ff       	jmp    801071c0 <alltraps>

80108076 <vector213>:
.globl vector213
vector213:
  pushl $0
80108076:	6a 00                	push   $0x0
  pushl $213
80108078:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010807d:	e9 3e f1 ff ff       	jmp    801071c0 <alltraps>

80108082 <vector214>:
.globl vector214
vector214:
  pushl $0
80108082:	6a 00                	push   $0x0
  pushl $214
80108084:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108089:	e9 32 f1 ff ff       	jmp    801071c0 <alltraps>

8010808e <vector215>:
.globl vector215
vector215:
  pushl $0
8010808e:	6a 00                	push   $0x0
  pushl $215
80108090:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108095:	e9 26 f1 ff ff       	jmp    801071c0 <alltraps>

8010809a <vector216>:
.globl vector216
vector216:
  pushl $0
8010809a:	6a 00                	push   $0x0
  pushl $216
8010809c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801080a1:	e9 1a f1 ff ff       	jmp    801071c0 <alltraps>

801080a6 <vector217>:
.globl vector217
vector217:
  pushl $0
801080a6:	6a 00                	push   $0x0
  pushl $217
801080a8:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801080ad:	e9 0e f1 ff ff       	jmp    801071c0 <alltraps>

801080b2 <vector218>:
.globl vector218
vector218:
  pushl $0
801080b2:	6a 00                	push   $0x0
  pushl $218
801080b4:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801080b9:	e9 02 f1 ff ff       	jmp    801071c0 <alltraps>

801080be <vector219>:
.globl vector219
vector219:
  pushl $0
801080be:	6a 00                	push   $0x0
  pushl $219
801080c0:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801080c5:	e9 f6 f0 ff ff       	jmp    801071c0 <alltraps>

801080ca <vector220>:
.globl vector220
vector220:
  pushl $0
801080ca:	6a 00                	push   $0x0
  pushl $220
801080cc:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801080d1:	e9 ea f0 ff ff       	jmp    801071c0 <alltraps>

801080d6 <vector221>:
.globl vector221
vector221:
  pushl $0
801080d6:	6a 00                	push   $0x0
  pushl $221
801080d8:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801080dd:	e9 de f0 ff ff       	jmp    801071c0 <alltraps>

801080e2 <vector222>:
.globl vector222
vector222:
  pushl $0
801080e2:	6a 00                	push   $0x0
  pushl $222
801080e4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801080e9:	e9 d2 f0 ff ff       	jmp    801071c0 <alltraps>

801080ee <vector223>:
.globl vector223
vector223:
  pushl $0
801080ee:	6a 00                	push   $0x0
  pushl $223
801080f0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801080f5:	e9 c6 f0 ff ff       	jmp    801071c0 <alltraps>

801080fa <vector224>:
.globl vector224
vector224:
  pushl $0
801080fa:	6a 00                	push   $0x0
  pushl $224
801080fc:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108101:	e9 ba f0 ff ff       	jmp    801071c0 <alltraps>

80108106 <vector225>:
.globl vector225
vector225:
  pushl $0
80108106:	6a 00                	push   $0x0
  pushl $225
80108108:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010810d:	e9 ae f0 ff ff       	jmp    801071c0 <alltraps>

80108112 <vector226>:
.globl vector226
vector226:
  pushl $0
80108112:	6a 00                	push   $0x0
  pushl $226
80108114:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108119:	e9 a2 f0 ff ff       	jmp    801071c0 <alltraps>

8010811e <vector227>:
.globl vector227
vector227:
  pushl $0
8010811e:	6a 00                	push   $0x0
  pushl $227
80108120:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108125:	e9 96 f0 ff ff       	jmp    801071c0 <alltraps>

8010812a <vector228>:
.globl vector228
vector228:
  pushl $0
8010812a:	6a 00                	push   $0x0
  pushl $228
8010812c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108131:	e9 8a f0 ff ff       	jmp    801071c0 <alltraps>

80108136 <vector229>:
.globl vector229
vector229:
  pushl $0
80108136:	6a 00                	push   $0x0
  pushl $229
80108138:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010813d:	e9 7e f0 ff ff       	jmp    801071c0 <alltraps>

80108142 <vector230>:
.globl vector230
vector230:
  pushl $0
80108142:	6a 00                	push   $0x0
  pushl $230
80108144:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108149:	e9 72 f0 ff ff       	jmp    801071c0 <alltraps>

8010814e <vector231>:
.globl vector231
vector231:
  pushl $0
8010814e:	6a 00                	push   $0x0
  pushl $231
80108150:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108155:	e9 66 f0 ff ff       	jmp    801071c0 <alltraps>

8010815a <vector232>:
.globl vector232
vector232:
  pushl $0
8010815a:	6a 00                	push   $0x0
  pushl $232
8010815c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108161:	e9 5a f0 ff ff       	jmp    801071c0 <alltraps>

80108166 <vector233>:
.globl vector233
vector233:
  pushl $0
80108166:	6a 00                	push   $0x0
  pushl $233
80108168:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010816d:	e9 4e f0 ff ff       	jmp    801071c0 <alltraps>

80108172 <vector234>:
.globl vector234
vector234:
  pushl $0
80108172:	6a 00                	push   $0x0
  pushl $234
80108174:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108179:	e9 42 f0 ff ff       	jmp    801071c0 <alltraps>

8010817e <vector235>:
.globl vector235
vector235:
  pushl $0
8010817e:	6a 00                	push   $0x0
  pushl $235
80108180:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108185:	e9 36 f0 ff ff       	jmp    801071c0 <alltraps>

8010818a <vector236>:
.globl vector236
vector236:
  pushl $0
8010818a:	6a 00                	push   $0x0
  pushl $236
8010818c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108191:	e9 2a f0 ff ff       	jmp    801071c0 <alltraps>

80108196 <vector237>:
.globl vector237
vector237:
  pushl $0
80108196:	6a 00                	push   $0x0
  pushl $237
80108198:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010819d:	e9 1e f0 ff ff       	jmp    801071c0 <alltraps>

801081a2 <vector238>:
.globl vector238
vector238:
  pushl $0
801081a2:	6a 00                	push   $0x0
  pushl $238
801081a4:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801081a9:	e9 12 f0 ff ff       	jmp    801071c0 <alltraps>

801081ae <vector239>:
.globl vector239
vector239:
  pushl $0
801081ae:	6a 00                	push   $0x0
  pushl $239
801081b0:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801081b5:	e9 06 f0 ff ff       	jmp    801071c0 <alltraps>

801081ba <vector240>:
.globl vector240
vector240:
  pushl $0
801081ba:	6a 00                	push   $0x0
  pushl $240
801081bc:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801081c1:	e9 fa ef ff ff       	jmp    801071c0 <alltraps>

801081c6 <vector241>:
.globl vector241
vector241:
  pushl $0
801081c6:	6a 00                	push   $0x0
  pushl $241
801081c8:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801081cd:	e9 ee ef ff ff       	jmp    801071c0 <alltraps>

801081d2 <vector242>:
.globl vector242
vector242:
  pushl $0
801081d2:	6a 00                	push   $0x0
  pushl $242
801081d4:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801081d9:	e9 e2 ef ff ff       	jmp    801071c0 <alltraps>

801081de <vector243>:
.globl vector243
vector243:
  pushl $0
801081de:	6a 00                	push   $0x0
  pushl $243
801081e0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801081e5:	e9 d6 ef ff ff       	jmp    801071c0 <alltraps>

801081ea <vector244>:
.globl vector244
vector244:
  pushl $0
801081ea:	6a 00                	push   $0x0
  pushl $244
801081ec:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801081f1:	e9 ca ef ff ff       	jmp    801071c0 <alltraps>

801081f6 <vector245>:
.globl vector245
vector245:
  pushl $0
801081f6:	6a 00                	push   $0x0
  pushl $245
801081f8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801081fd:	e9 be ef ff ff       	jmp    801071c0 <alltraps>

80108202 <vector246>:
.globl vector246
vector246:
  pushl $0
80108202:	6a 00                	push   $0x0
  pushl $246
80108204:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108209:	e9 b2 ef ff ff       	jmp    801071c0 <alltraps>

8010820e <vector247>:
.globl vector247
vector247:
  pushl $0
8010820e:	6a 00                	push   $0x0
  pushl $247
80108210:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108215:	e9 a6 ef ff ff       	jmp    801071c0 <alltraps>

8010821a <vector248>:
.globl vector248
vector248:
  pushl $0
8010821a:	6a 00                	push   $0x0
  pushl $248
8010821c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108221:	e9 9a ef ff ff       	jmp    801071c0 <alltraps>

80108226 <vector249>:
.globl vector249
vector249:
  pushl $0
80108226:	6a 00                	push   $0x0
  pushl $249
80108228:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010822d:	e9 8e ef ff ff       	jmp    801071c0 <alltraps>

80108232 <vector250>:
.globl vector250
vector250:
  pushl $0
80108232:	6a 00                	push   $0x0
  pushl $250
80108234:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108239:	e9 82 ef ff ff       	jmp    801071c0 <alltraps>

8010823e <vector251>:
.globl vector251
vector251:
  pushl $0
8010823e:	6a 00                	push   $0x0
  pushl $251
80108240:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108245:	e9 76 ef ff ff       	jmp    801071c0 <alltraps>

8010824a <vector252>:
.globl vector252
vector252:
  pushl $0
8010824a:	6a 00                	push   $0x0
  pushl $252
8010824c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108251:	e9 6a ef ff ff       	jmp    801071c0 <alltraps>

80108256 <vector253>:
.globl vector253
vector253:
  pushl $0
80108256:	6a 00                	push   $0x0
  pushl $253
80108258:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010825d:	e9 5e ef ff ff       	jmp    801071c0 <alltraps>

80108262 <vector254>:
.globl vector254
vector254:
  pushl $0
80108262:	6a 00                	push   $0x0
  pushl $254
80108264:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108269:	e9 52 ef ff ff       	jmp    801071c0 <alltraps>

8010826e <vector255>:
.globl vector255
vector255:
  pushl $0
8010826e:	6a 00                	push   $0x0
  pushl $255
80108270:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108275:	e9 46 ef ff ff       	jmp    801071c0 <alltraps>
	...

8010827c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010827c:	55                   	push   %ebp
8010827d:	89 e5                	mov    %esp,%ebp
8010827f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108282:	8b 45 0c             	mov    0xc(%ebp),%eax
80108285:	48                   	dec    %eax
80108286:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010828a:	8b 45 08             	mov    0x8(%ebp),%eax
8010828d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108291:	8b 45 08             	mov    0x8(%ebp),%eax
80108294:	c1 e8 10             	shr    $0x10,%eax
80108297:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010829b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010829e:	0f 01 10             	lgdtl  (%eax)
}
801082a1:	c9                   	leave  
801082a2:	c3                   	ret    

801082a3 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801082a3:	55                   	push   %ebp
801082a4:	89 e5                	mov    %esp,%ebp
801082a6:	83 ec 04             	sub    $0x4,%esp
801082a9:	8b 45 08             	mov    0x8(%ebp),%eax
801082ac:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801082b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082b3:	0f 00 d8             	ltr    %ax
}
801082b6:	c9                   	leave  
801082b7:	c3                   	ret    

801082b8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
801082b8:	55                   	push   %ebp
801082b9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801082bb:	8b 45 08             	mov    0x8(%ebp),%eax
801082be:	0f 22 d8             	mov    %eax,%cr3
}
801082c1:	5d                   	pop    %ebp
801082c2:	c3                   	ret    

801082c3 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801082c3:	55                   	push   %ebp
801082c4:	89 e5                	mov    %esp,%ebp
801082c6:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801082c9:	e8 48 c1 ff ff       	call   80104416 <cpuid>
801082ce:	89 c2                	mov    %eax,%edx
801082d0:	89 d0                	mov    %edx,%eax
801082d2:	c1 e0 02             	shl    $0x2,%eax
801082d5:	01 d0                	add    %edx,%eax
801082d7:	01 c0                	add    %eax,%eax
801082d9:	01 d0                	add    %edx,%eax
801082db:	c1 e0 04             	shl    $0x4,%eax
801082de:	05 a0 5c 11 80       	add    $0x80115ca0,%eax
801082e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801082e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e9:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801082ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f2:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801082f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fb:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801082ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108302:	8a 50 7d             	mov    0x7d(%eax),%dl
80108305:	83 e2 f0             	and    $0xfffffff0,%edx
80108308:	83 ca 0a             	or     $0xa,%edx
8010830b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010830e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108311:	8a 50 7d             	mov    0x7d(%eax),%dl
80108314:	83 ca 10             	or     $0x10,%edx
80108317:	88 50 7d             	mov    %dl,0x7d(%eax)
8010831a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831d:	8a 50 7d             	mov    0x7d(%eax),%dl
80108320:	83 e2 9f             	and    $0xffffff9f,%edx
80108323:	88 50 7d             	mov    %dl,0x7d(%eax)
80108326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108329:	8a 50 7d             	mov    0x7d(%eax),%dl
8010832c:	83 ca 80             	or     $0xffffff80,%edx
8010832f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108335:	8a 50 7e             	mov    0x7e(%eax),%dl
80108338:	83 ca 0f             	or     $0xf,%edx
8010833b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010833e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108341:	8a 50 7e             	mov    0x7e(%eax),%dl
80108344:	83 e2 ef             	and    $0xffffffef,%edx
80108347:	88 50 7e             	mov    %dl,0x7e(%eax)
8010834a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834d:	8a 50 7e             	mov    0x7e(%eax),%dl
80108350:	83 e2 df             	and    $0xffffffdf,%edx
80108353:	88 50 7e             	mov    %dl,0x7e(%eax)
80108356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108359:	8a 50 7e             	mov    0x7e(%eax),%dl
8010835c:	83 ca 40             	or     $0x40,%edx
8010835f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108365:	8a 50 7e             	mov    0x7e(%eax),%dl
80108368:	83 ca 80             	or     $0xffffff80,%edx
8010836b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010836e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108371:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108378:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010837f:	ff ff 
80108381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108384:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010838b:	00 00 
8010838d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108390:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839a:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801083a0:	83 e2 f0             	and    $0xfffffff0,%edx
801083a3:	83 ca 02             	or     $0x2,%edx
801083a6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801083ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083af:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801083b5:	83 ca 10             	or     $0x10,%edx
801083b8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801083be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c1:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801083c7:	83 e2 9f             	and    $0xffffff9f,%edx
801083ca:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801083d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d3:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801083d9:	83 ca 80             	or     $0xffffff80,%edx
801083dc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801083e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e5:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801083eb:	83 ca 0f             	or     $0xf,%edx
801083ee:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801083f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f7:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801083fd:	83 e2 ef             	and    $0xffffffef,%edx
80108400:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108409:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010840f:	83 e2 df             	and    $0xffffffdf,%edx
80108412:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841b:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108421:	83 ca 40             	or     $0x40,%edx
80108424:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010842a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108433:	83 ca 80             	or     $0xffffff80,%edx
80108436:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010843c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843f:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108449:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80108450:	ff ff 
80108452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108455:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010845c:	00 00 
8010845e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108461:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80108468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846b:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108471:	83 e2 f0             	and    $0xfffffff0,%edx
80108474:	83 ca 0a             	or     $0xa,%edx
80108477:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010847d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108480:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108486:	83 ca 10             	or     $0x10,%edx
80108489:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010848f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108492:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108498:	83 ca 60             	or     $0x60,%edx
8010849b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801084a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a4:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801084aa:	83 ca 80             	or     $0xffffff80,%edx
801084ad:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801084b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b6:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801084bc:	83 ca 0f             	or     $0xf,%edx
801084bf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801084c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c8:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801084ce:	83 e2 ef             	and    $0xffffffef,%edx
801084d1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801084d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084da:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801084e0:	83 e2 df             	and    $0xffffffdf,%edx
801084e3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801084e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ec:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801084f2:	83 ca 40             	or     $0x40,%edx
801084f5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801084fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fe:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108504:	83 ca 80             	or     $0xffffff80,%edx
80108507:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010850d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108510:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851a:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108521:	ff ff 
80108523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108526:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010852d:	00 00 
8010852f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108532:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853c:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108542:	83 e2 f0             	and    $0xfffffff0,%edx
80108545:	83 ca 02             	or     $0x2,%edx
80108548:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108551:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108557:	83 ca 10             	or     $0x10,%edx
8010855a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108563:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108569:	83 ca 60             	or     $0x60,%edx
8010856c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108575:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010857b:	83 ca 80             	or     $0xffffff80,%edx
8010857e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108587:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010858d:	83 ca 0f             	or     $0xf,%edx
80108590:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108599:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010859f:	83 e2 ef             	and    $0xffffffef,%edx
801085a2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ab:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801085b1:	83 e2 df             	and    $0xffffffdf,%edx
801085b4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bd:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801085c3:	83 ca 40             	or     $0x40,%edx
801085c6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085cf:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801085d5:	83 ca 80             	or     $0xffffff80,%edx
801085d8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801085de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801085e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085eb:	83 c0 70             	add    $0x70,%eax
801085ee:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801085f5:	00 
801085f6:	89 04 24             	mov    %eax,(%esp)
801085f9:	e8 7e fc ff ff       	call   8010827c <lgdt>
}
801085fe:	c9                   	leave  
801085ff:	c3                   	ret    

80108600 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108600:	55                   	push   %ebp
80108601:	89 e5                	mov    %esp,%ebp
80108603:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108606:	8b 45 0c             	mov    0xc(%ebp),%eax
80108609:	c1 e8 16             	shr    $0x16,%eax
8010860c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108613:	8b 45 08             	mov    0x8(%ebp),%eax
80108616:	01 d0                	add    %edx,%eax
80108618:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010861b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010861e:	8b 00                	mov    (%eax),%eax
80108620:	83 e0 01             	and    $0x1,%eax
80108623:	85 c0                	test   %eax,%eax
80108625:	74 14                	je     8010863b <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010862a:	8b 00                	mov    (%eax),%eax
8010862c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108631:	05 00 00 00 80       	add    $0x80000000,%eax
80108636:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108639:	eb 48                	jmp    80108683 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010863b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010863f:	74 0e                	je     8010864f <walkpgdir+0x4f>
80108641:	e8 59 a8 ff ff       	call   80102e9f <kalloc>
80108646:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108649:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010864d:	75 07                	jne    80108656 <walkpgdir+0x56>
      return 0;
8010864f:	b8 00 00 00 00       	mov    $0x0,%eax
80108654:	eb 44                	jmp    8010869a <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108656:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010865d:	00 
8010865e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108665:	00 
80108666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108669:	89 04 24             	mov    %eax,(%esp)
8010866c:	e8 b1 d0 ff ff       	call   80105722 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80108671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108674:	05 00 00 00 80       	add    $0x80000000,%eax
80108679:	83 c8 07             	or     $0x7,%eax
8010867c:	89 c2                	mov    %eax,%edx
8010867e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108681:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108683:	8b 45 0c             	mov    0xc(%ebp),%eax
80108686:	c1 e8 0c             	shr    $0xc,%eax
80108689:	25 ff 03 00 00       	and    $0x3ff,%eax
8010868e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108698:	01 d0                	add    %edx,%eax
}
8010869a:	c9                   	leave  
8010869b:	c3                   	ret    

8010869c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010869c:	55                   	push   %ebp
8010869d:	89 e5                	mov    %esp,%ebp
8010869f:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801086a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801086a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801086ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801086b0:	8b 45 10             	mov    0x10(%ebp),%eax
801086b3:	01 d0                	add    %edx,%eax
801086b5:	48                   	dec    %eax
801086b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801086be:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801086c5:	00 
801086c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801086cd:	8b 45 08             	mov    0x8(%ebp),%eax
801086d0:	89 04 24             	mov    %eax,(%esp)
801086d3:	e8 28 ff ff ff       	call   80108600 <walkpgdir>
801086d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086df:	75 07                	jne    801086e8 <mappages+0x4c>
      return -1;
801086e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801086e6:	eb 48                	jmp    80108730 <mappages+0x94>
    if(*pte & PTE_P)
801086e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086eb:	8b 00                	mov    (%eax),%eax
801086ed:	83 e0 01             	and    $0x1,%eax
801086f0:	85 c0                	test   %eax,%eax
801086f2:	74 0c                	je     80108700 <mappages+0x64>
      panic("remap");
801086f4:	c7 04 24 10 a0 10 80 	movl   $0x8010a010,(%esp)
801086fb:	e8 54 7e ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108700:	8b 45 18             	mov    0x18(%ebp),%eax
80108703:	0b 45 14             	or     0x14(%ebp),%eax
80108706:	83 c8 01             	or     $0x1,%eax
80108709:	89 c2                	mov    %eax,%edx
8010870b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010870e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108713:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108716:	75 08                	jne    80108720 <mappages+0x84>
      break;
80108718:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108719:	b8 00 00 00 00       	mov    $0x0,%eax
8010871e:	eb 10                	jmp    80108730 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108720:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108727:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010872e:	eb 8e                	jmp    801086be <mappages+0x22>
  return 0;
}
80108730:	c9                   	leave  
80108731:	c3                   	ret    

80108732 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108732:	55                   	push   %ebp
80108733:	89 e5                	mov    %esp,%ebp
80108735:	53                   	push   %ebx
80108736:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108739:	e8 61 a7 ff ff       	call   80102e9f <kalloc>
8010873e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108741:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108745:	75 0a                	jne    80108751 <setupkvm+0x1f>
    return 0;
80108747:	b8 00 00 00 00       	mov    $0x0,%eax
8010874c:	e9 84 00 00 00       	jmp    801087d5 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80108751:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108758:	00 
80108759:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108760:	00 
80108761:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108764:	89 04 24             	mov    %eax,(%esp)
80108767:	e8 b6 cf ff ff       	call   80105722 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010876c:	c7 45 f4 20 d5 10 80 	movl   $0x8010d520,-0xc(%ebp)
80108773:	eb 54                	jmp    801087c9 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108778:	8b 48 0c             	mov    0xc(%eax),%ecx
8010877b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877e:	8b 50 04             	mov    0x4(%eax),%edx
80108781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108784:	8b 58 08             	mov    0x8(%eax),%ebx
80108787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878a:	8b 40 04             	mov    0x4(%eax),%eax
8010878d:	29 c3                	sub    %eax,%ebx
8010878f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108792:	8b 00                	mov    (%eax),%eax
80108794:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108798:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010879c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801087a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801087a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087a7:	89 04 24             	mov    %eax,(%esp)
801087aa:	e8 ed fe ff ff       	call   8010869c <mappages>
801087af:	85 c0                	test   %eax,%eax
801087b1:	79 12                	jns    801087c5 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
801087b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b6:	89 04 24             	mov    %eax,(%esp)
801087b9:	e8 1a 05 00 00       	call   80108cd8 <freevm>
      return 0;
801087be:	b8 00 00 00 00       	mov    $0x0,%eax
801087c3:	eb 10                	jmp    801087d5 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801087c5:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801087c9:	81 7d f4 60 d5 10 80 	cmpl   $0x8010d560,-0xc(%ebp)
801087d0:	72 a3                	jb     80108775 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
801087d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801087d5:	83 c4 34             	add    $0x34,%esp
801087d8:	5b                   	pop    %ebx
801087d9:	5d                   	pop    %ebp
801087da:	c3                   	ret    

801087db <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801087db:	55                   	push   %ebp
801087dc:	89 e5                	mov    %esp,%ebp
801087de:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801087e1:	e8 4c ff ff ff       	call   80108732 <setupkvm>
801087e6:	a3 c4 8b 11 80       	mov    %eax,0x80118bc4
  switchkvm();
801087eb:	e8 02 00 00 00       	call   801087f2 <switchkvm>
}
801087f0:	c9                   	leave  
801087f1:	c3                   	ret    

801087f2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801087f2:	55                   	push   %ebp
801087f3:	89 e5                	mov    %esp,%ebp
801087f5:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801087f8:	a1 c4 8b 11 80       	mov    0x80118bc4,%eax
801087fd:	05 00 00 00 80       	add    $0x80000000,%eax
80108802:	89 04 24             	mov    %eax,(%esp)
80108805:	e8 ae fa ff ff       	call   801082b8 <lcr3>
}
8010880a:	c9                   	leave  
8010880b:	c3                   	ret    

8010880c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010880c:	55                   	push   %ebp
8010880d:	89 e5                	mov    %esp,%ebp
8010880f:	57                   	push   %edi
80108810:	56                   	push   %esi
80108811:	53                   	push   %ebx
80108812:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108815:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108819:	75 0c                	jne    80108827 <switchuvm+0x1b>
    panic("switchuvm: no process");
8010881b:	c7 04 24 16 a0 10 80 	movl   $0x8010a016,(%esp)
80108822:	e8 2d 7d ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80108827:	8b 45 08             	mov    0x8(%ebp),%eax
8010882a:	8b 40 08             	mov    0x8(%eax),%eax
8010882d:	85 c0                	test   %eax,%eax
8010882f:	75 0c                	jne    8010883d <switchuvm+0x31>
    panic("switchuvm: no kstack");
80108831:	c7 04 24 2c a0 10 80 	movl   $0x8010a02c,(%esp)
80108838:	e8 17 7d ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
8010883d:	8b 45 08             	mov    0x8(%ebp),%eax
80108840:	8b 40 04             	mov    0x4(%eax),%eax
80108843:	85 c0                	test   %eax,%eax
80108845:	75 0c                	jne    80108853 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80108847:	c7 04 24 41 a0 10 80 	movl   $0x8010a041,(%esp)
8010884e:	e8 01 7d ff ff       	call   80100554 <panic>

  pushcli();
80108853:	e8 c6 cd ff ff       	call   8010561e <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108858:	e8 fe bb ff ff       	call   8010445b <mycpu>
8010885d:	89 c3                	mov    %eax,%ebx
8010885f:	e8 f7 bb ff ff       	call   8010445b <mycpu>
80108864:	83 c0 08             	add    $0x8,%eax
80108867:	89 c6                	mov    %eax,%esi
80108869:	e8 ed bb ff ff       	call   8010445b <mycpu>
8010886e:	83 c0 08             	add    $0x8,%eax
80108871:	c1 e8 10             	shr    $0x10,%eax
80108874:	89 c7                	mov    %eax,%edi
80108876:	e8 e0 bb ff ff       	call   8010445b <mycpu>
8010887b:	83 c0 08             	add    $0x8,%eax
8010887e:	c1 e8 18             	shr    $0x18,%eax
80108881:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108888:	67 00 
8010888a:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108891:	89 f9                	mov    %edi,%ecx
80108893:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108899:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010889f:	83 e2 f0             	and    $0xfffffff0,%edx
801088a2:	83 ca 09             	or     $0x9,%edx
801088a5:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801088ab:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801088b1:	83 ca 10             	or     $0x10,%edx
801088b4:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801088ba:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801088c0:	83 e2 9f             	and    $0xffffff9f,%edx
801088c3:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801088c9:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801088cf:	83 ca 80             	or     $0xffffff80,%edx
801088d2:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801088d8:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801088de:	83 e2 f0             	and    $0xfffffff0,%edx
801088e1:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801088e7:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801088ed:	83 e2 ef             	and    $0xffffffef,%edx
801088f0:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801088f6:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801088fc:	83 e2 df             	and    $0xffffffdf,%edx
801088ff:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108905:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010890b:	83 ca 40             	or     $0x40,%edx
8010890e:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108914:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010891a:	83 e2 7f             	and    $0x7f,%edx
8010891d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108923:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108929:	e8 2d bb ff ff       	call   8010445b <mycpu>
8010892e:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108934:	83 e2 ef             	and    $0xffffffef,%edx
80108937:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010893d:	e8 19 bb ff ff       	call   8010445b <mycpu>
80108942:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108948:	e8 0e bb ff ff       	call   8010445b <mycpu>
8010894d:	8b 55 08             	mov    0x8(%ebp),%edx
80108950:	8b 52 08             	mov    0x8(%edx),%edx
80108953:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108959:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010895c:	e8 fa ba ff ff       	call   8010445b <mycpu>
80108961:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108967:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
8010896e:	e8 30 f9 ff ff       	call   801082a3 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108973:	8b 45 08             	mov    0x8(%ebp),%eax
80108976:	8b 40 04             	mov    0x4(%eax),%eax
80108979:	05 00 00 00 80       	add    $0x80000000,%eax
8010897e:	89 04 24             	mov    %eax,(%esp)
80108981:	e8 32 f9 ff ff       	call   801082b8 <lcr3>
  popcli();
80108986:	e8 dd cc ff ff       	call   80105668 <popcli>
}
8010898b:	83 c4 1c             	add    $0x1c,%esp
8010898e:	5b                   	pop    %ebx
8010898f:	5e                   	pop    %esi
80108990:	5f                   	pop    %edi
80108991:	5d                   	pop    %ebp
80108992:	c3                   	ret    

80108993 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108993:	55                   	push   %ebp
80108994:	89 e5                	mov    %esp,%ebp
80108996:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108999:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801089a0:	76 0c                	jbe    801089ae <inituvm+0x1b>
    panic("inituvm: more than a page");
801089a2:	c7 04 24 55 a0 10 80 	movl   $0x8010a055,(%esp)
801089a9:	e8 a6 7b ff ff       	call   80100554 <panic>
  mem = kalloc();
801089ae:	e8 ec a4 ff ff       	call   80102e9f <kalloc>
801089b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801089b6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801089bd:	00 
801089be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801089c5:	00 
801089c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c9:	89 04 24             	mov    %eax,(%esp)
801089cc:	e8 51 cd ff ff       	call   80105722 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801089d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d4:	05 00 00 00 80       	add    $0x80000000,%eax
801089d9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801089e0:	00 
801089e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
801089e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801089ec:	00 
801089ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801089f4:	00 
801089f5:	8b 45 08             	mov    0x8(%ebp),%eax
801089f8:	89 04 24             	mov    %eax,(%esp)
801089fb:	e8 9c fc ff ff       	call   8010869c <mappages>
  memmove(mem, init, sz);
80108a00:	8b 45 10             	mov    0x10(%ebp),%eax
80108a03:	89 44 24 08          	mov    %eax,0x8(%esp)
80108a07:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a11:	89 04 24             	mov    %eax,(%esp)
80108a14:	e8 d2 cd ff ff       	call   801057eb <memmove>
}
80108a19:	c9                   	leave  
80108a1a:	c3                   	ret    

80108a1b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108a1b:	55                   	push   %ebp
80108a1c:	89 e5                	mov    %esp,%ebp
80108a1e:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108a21:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a24:	25 ff 0f 00 00       	and    $0xfff,%eax
80108a29:	85 c0                	test   %eax,%eax
80108a2b:	74 0c                	je     80108a39 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108a2d:	c7 04 24 70 a0 10 80 	movl   $0x8010a070,(%esp)
80108a34:	e8 1b 7b ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108a39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a40:	e9 a6 00 00 00       	jmp    80108aeb <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a48:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a4b:	01 d0                	add    %edx,%eax
80108a4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a54:	00 
80108a55:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a59:	8b 45 08             	mov    0x8(%ebp),%eax
80108a5c:	89 04 24             	mov    %eax,(%esp)
80108a5f:	e8 9c fb ff ff       	call   80108600 <walkpgdir>
80108a64:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a6b:	75 0c                	jne    80108a79 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108a6d:	c7 04 24 93 a0 10 80 	movl   $0x8010a093,(%esp)
80108a74:	e8 db 7a ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108a79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a7c:	8b 00                	mov    (%eax),%eax
80108a7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a83:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a89:	8b 55 18             	mov    0x18(%ebp),%edx
80108a8c:	29 c2                	sub    %eax,%edx
80108a8e:	89 d0                	mov    %edx,%eax
80108a90:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108a95:	77 0f                	ja     80108aa6 <loaduvm+0x8b>
      n = sz - i;
80108a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a9a:	8b 55 18             	mov    0x18(%ebp),%edx
80108a9d:	29 c2                	sub    %eax,%edx
80108a9f:	89 d0                	mov    %edx,%eax
80108aa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108aa4:	eb 07                	jmp    80108aad <loaduvm+0x92>
    else
      n = PGSIZE;
80108aa6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab0:	8b 55 14             	mov    0x14(%ebp),%edx
80108ab3:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108ab6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ab9:	05 00 00 00 80       	add    $0x80000000,%eax
80108abe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108ac1:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108ac5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108acd:	8b 45 10             	mov    0x10(%ebp),%eax
80108ad0:	89 04 24             	mov    %eax,(%esp)
80108ad3:	e8 81 94 ff ff       	call   80101f59 <readi>
80108ad8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108adb:	74 07                	je     80108ae4 <loaduvm+0xc9>
      return -1;
80108add:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ae2:	eb 18                	jmp    80108afc <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108ae4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aee:	3b 45 18             	cmp    0x18(%ebp),%eax
80108af1:	0f 82 4e ff ff ff    	jb     80108a45 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108af7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108afc:	c9                   	leave  
80108afd:	c3                   	ret    

80108afe <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108afe:	55                   	push   %ebp
80108aff:	89 e5                	mov    %esp,%ebp
80108b01:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108b04:	8b 45 10             	mov    0x10(%ebp),%eax
80108b07:	85 c0                	test   %eax,%eax
80108b09:	79 0a                	jns    80108b15 <allocuvm+0x17>
    return 0;
80108b0b:	b8 00 00 00 00       	mov    $0x0,%eax
80108b10:	e9 fd 00 00 00       	jmp    80108c12 <allocuvm+0x114>
  if(newsz < oldsz)
80108b15:	8b 45 10             	mov    0x10(%ebp),%eax
80108b18:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b1b:	73 08                	jae    80108b25 <allocuvm+0x27>
    return oldsz;
80108b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b20:	e9 ed 00 00 00       	jmp    80108c12 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108b25:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b28:	05 ff 0f 00 00       	add    $0xfff,%eax
80108b2d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108b35:	e9 c9 00 00 00       	jmp    80108c03 <allocuvm+0x105>
    mem = kalloc();
80108b3a:	e8 60 a3 ff ff       	call   80102e9f <kalloc>
80108b3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108b42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b46:	75 2f                	jne    80108b77 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108b48:	c7 04 24 b1 a0 10 80 	movl   $0x8010a0b1,(%esp)
80108b4f:	e8 6d 78 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108b54:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b57:	89 44 24 08          	mov    %eax,0x8(%esp)
80108b5b:	8b 45 10             	mov    0x10(%ebp),%eax
80108b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b62:	8b 45 08             	mov    0x8(%ebp),%eax
80108b65:	89 04 24             	mov    %eax,(%esp)
80108b68:	e8 a7 00 00 00       	call   80108c14 <deallocuvm>
      return 0;
80108b6d:	b8 00 00 00 00       	mov    $0x0,%eax
80108b72:	e9 9b 00 00 00       	jmp    80108c12 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108b77:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b7e:	00 
80108b7f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b86:	00 
80108b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b8a:	89 04 24             	mov    %eax,(%esp)
80108b8d:	e8 90 cb ff ff       	call   80105722 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b95:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108ba5:	00 
80108ba6:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108baa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108bb1:	00 
80108bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80108bb9:	89 04 24             	mov    %eax,(%esp)
80108bbc:	e8 db fa ff ff       	call   8010869c <mappages>
80108bc1:	85 c0                	test   %eax,%eax
80108bc3:	79 37                	jns    80108bfc <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108bc5:	c7 04 24 c9 a0 10 80 	movl   $0x8010a0c9,(%esp)
80108bcc:	e8 f0 77 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bd4:	89 44 24 08          	mov    %eax,0x8(%esp)
80108bd8:	8b 45 10             	mov    0x10(%ebp),%eax
80108bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80108be2:	89 04 24             	mov    %eax,(%esp)
80108be5:	e8 2a 00 00 00       	call   80108c14 <deallocuvm>
      kfree(mem);
80108bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bed:	89 04 24             	mov    %eax,(%esp)
80108bf0:	e8 d8 a1 ff ff       	call   80102dcd <kfree>
      return 0;
80108bf5:	b8 00 00 00 00       	mov    $0x0,%eax
80108bfa:	eb 16                	jmp    80108c12 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108bfc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c06:	3b 45 10             	cmp    0x10(%ebp),%eax
80108c09:	0f 82 2b ff ff ff    	jb     80108b3a <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108c0f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108c12:	c9                   	leave  
80108c13:	c3                   	ret    

80108c14 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108c14:	55                   	push   %ebp
80108c15:	89 e5                	mov    %esp,%ebp
80108c17:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108c1a:	8b 45 10             	mov    0x10(%ebp),%eax
80108c1d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c20:	72 08                	jb     80108c2a <deallocuvm+0x16>
    return oldsz;
80108c22:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c25:	e9 ac 00 00 00       	jmp    80108cd6 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108c2a:	8b 45 10             	mov    0x10(%ebp),%eax
80108c2d:	05 ff 0f 00 00       	add    $0xfff,%eax
80108c32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108c3a:	e9 88 00 00 00       	jmp    80108cc7 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c42:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108c49:	00 
80108c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80108c51:	89 04 24             	mov    %eax,(%esp)
80108c54:	e8 a7 f9 ff ff       	call   80108600 <walkpgdir>
80108c59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108c5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c60:	75 14                	jne    80108c76 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c65:	c1 e8 16             	shr    $0x16,%eax
80108c68:	40                   	inc    %eax
80108c69:	c1 e0 16             	shl    $0x16,%eax
80108c6c:	2d 00 10 00 00       	sub    $0x1000,%eax
80108c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108c74:	eb 4a                	jmp    80108cc0 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c79:	8b 00                	mov    (%eax),%eax
80108c7b:	83 e0 01             	and    $0x1,%eax
80108c7e:	85 c0                	test   %eax,%eax
80108c80:	74 3e                	je     80108cc0 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c85:	8b 00                	mov    (%eax),%eax
80108c87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108c8f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108c93:	75 0c                	jne    80108ca1 <deallocuvm+0x8d>
        panic("kfree");
80108c95:	c7 04 24 e5 a0 10 80 	movl   $0x8010a0e5,(%esp)
80108c9c:	e8 b3 78 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108ca1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ca4:	05 00 00 00 80       	add    $0x80000000,%eax
80108ca9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108cac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108caf:	89 04 24             	mov    %eax,(%esp)
80108cb2:	e8 16 a1 ff ff       	call   80102dcd <kfree>
      *pte = 0;
80108cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108cc0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cca:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ccd:	0f 82 6c ff ff ff    	jb     80108c3f <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108cd3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108cd6:	c9                   	leave  
80108cd7:	c3                   	ret    

80108cd8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108cd8:	55                   	push   %ebp
80108cd9:	89 e5                	mov    %esp,%ebp
80108cdb:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108cde:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108ce2:	75 0c                	jne    80108cf0 <freevm+0x18>
    panic("freevm: no pgdir");
80108ce4:	c7 04 24 eb a0 10 80 	movl   $0x8010a0eb,(%esp)
80108ceb:	e8 64 78 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108cf0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108cf7:	00 
80108cf8:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108cff:	80 
80108d00:	8b 45 08             	mov    0x8(%ebp),%eax
80108d03:	89 04 24             	mov    %eax,(%esp)
80108d06:	e8 09 ff ff ff       	call   80108c14 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108d0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d12:	eb 44                	jmp    80108d58 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d17:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80108d21:	01 d0                	add    %edx,%eax
80108d23:	8b 00                	mov    (%eax),%eax
80108d25:	83 e0 01             	and    $0x1,%eax
80108d28:	85 c0                	test   %eax,%eax
80108d2a:	74 29                	je     80108d55 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d2f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d36:	8b 45 08             	mov    0x8(%ebp),%eax
80108d39:	01 d0                	add    %edx,%eax
80108d3b:	8b 00                	mov    (%eax),%eax
80108d3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d42:	05 00 00 00 80       	add    $0x80000000,%eax
80108d47:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d4d:	89 04 24             	mov    %eax,(%esp)
80108d50:	e8 78 a0 ff ff       	call   80102dcd <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108d55:	ff 45 f4             	incl   -0xc(%ebp)
80108d58:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108d5f:	76 b3                	jbe    80108d14 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108d61:	8b 45 08             	mov    0x8(%ebp),%eax
80108d64:	89 04 24             	mov    %eax,(%esp)
80108d67:	e8 61 a0 ff ff       	call   80102dcd <kfree>
}
80108d6c:	c9                   	leave  
80108d6d:	c3                   	ret    

80108d6e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108d6e:	55                   	push   %ebp
80108d6f:	89 e5                	mov    %esp,%ebp
80108d71:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108d74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d7b:	00 
80108d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d83:	8b 45 08             	mov    0x8(%ebp),%eax
80108d86:	89 04 24             	mov    %eax,(%esp)
80108d89:	e8 72 f8 ff ff       	call   80108600 <walkpgdir>
80108d8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108d91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108d95:	75 0c                	jne    80108da3 <clearpteu+0x35>
    panic("clearpteu");
80108d97:	c7 04 24 fc a0 10 80 	movl   $0x8010a0fc,(%esp)
80108d9e:	e8 b1 77 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da6:	8b 00                	mov    (%eax),%eax
80108da8:	83 e0 fb             	and    $0xfffffffb,%eax
80108dab:	89 c2                	mov    %eax,%edx
80108dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108db0:	89 10                	mov    %edx,(%eax)
}
80108db2:	c9                   	leave  
80108db3:	c3                   	ret    

80108db4 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108db4:	55                   	push   %ebp
80108db5:	89 e5                	mov    %esp,%ebp
80108db7:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108dba:	e8 73 f9 ff ff       	call   80108732 <setupkvm>
80108dbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108dc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108dc6:	75 0a                	jne    80108dd2 <copyuvm+0x1e>
    return 0;
80108dc8:	b8 00 00 00 00       	mov    $0x0,%eax
80108dcd:	e9 f8 00 00 00       	jmp    80108eca <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108dd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108dd9:	e9 cb 00 00 00       	jmp    80108ea9 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108de8:	00 
80108de9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ded:	8b 45 08             	mov    0x8(%ebp),%eax
80108df0:	89 04 24             	mov    %eax,(%esp)
80108df3:	e8 08 f8 ff ff       	call   80108600 <walkpgdir>
80108df8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108dfb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108dff:	75 0c                	jne    80108e0d <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108e01:	c7 04 24 06 a1 10 80 	movl   $0x8010a106,(%esp)
80108e08:	e8 47 77 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108e0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e10:	8b 00                	mov    (%eax),%eax
80108e12:	83 e0 01             	and    $0x1,%eax
80108e15:	85 c0                	test   %eax,%eax
80108e17:	75 0c                	jne    80108e25 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108e19:	c7 04 24 20 a1 10 80 	movl   $0x8010a120,(%esp)
80108e20:	e8 2f 77 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108e25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e28:	8b 00                	mov    (%eax),%eax
80108e2a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108e32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e35:	8b 00                	mov    (%eax),%eax
80108e37:	25 ff 0f 00 00       	and    $0xfff,%eax
80108e3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108e3f:	e8 5b a0 ff ff       	call   80102e9f <kalloc>
80108e44:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108e47:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108e4b:	75 02                	jne    80108e4f <copyuvm+0x9b>
      goto bad;
80108e4d:	eb 6b                	jmp    80108eba <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108e4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e52:	05 00 00 00 80       	add    $0x80000000,%eax
80108e57:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108e5e:	00 
80108e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e66:	89 04 24             	mov    %eax,(%esp)
80108e69:	e8 7d c9 ff ff       	call   801057eb <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108e6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108e71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e74:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e7d:	89 54 24 10          	mov    %edx,0x10(%esp)
80108e81:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108e85:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108e8c:	00 
80108e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e94:	89 04 24             	mov    %eax,(%esp)
80108e97:	e8 00 f8 ff ff       	call   8010869c <mappages>
80108e9c:	85 c0                	test   %eax,%eax
80108e9e:	79 02                	jns    80108ea2 <copyuvm+0xee>
      goto bad;
80108ea0:	eb 18                	jmp    80108eba <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108ea2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eac:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108eaf:	0f 82 29 ff ff ff    	jb     80108dde <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb8:	eb 10                	jmp    80108eca <copyuvm+0x116>

bad:
  freevm(d);
80108eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ebd:	89 04 24             	mov    %eax,(%esp)
80108ec0:	e8 13 fe ff ff       	call   80108cd8 <freevm>
  return 0;
80108ec5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108eca:	c9                   	leave  
80108ecb:	c3                   	ret    

80108ecc <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108ecc:	55                   	push   %ebp
80108ecd:	89 e5                	mov    %esp,%ebp
80108ecf:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108ed2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ed9:	00 
80108eda:	8b 45 0c             	mov    0xc(%ebp),%eax
80108edd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ee4:	89 04 24             	mov    %eax,(%esp)
80108ee7:	e8 14 f7 ff ff       	call   80108600 <walkpgdir>
80108eec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef2:	8b 00                	mov    (%eax),%eax
80108ef4:	83 e0 01             	and    $0x1,%eax
80108ef7:	85 c0                	test   %eax,%eax
80108ef9:	75 07                	jne    80108f02 <uva2ka+0x36>
    return 0;
80108efb:	b8 00 00 00 00       	mov    $0x0,%eax
80108f00:	eb 22                	jmp    80108f24 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f05:	8b 00                	mov    (%eax),%eax
80108f07:	83 e0 04             	and    $0x4,%eax
80108f0a:	85 c0                	test   %eax,%eax
80108f0c:	75 07                	jne    80108f15 <uva2ka+0x49>
    return 0;
80108f0e:	b8 00 00 00 00       	mov    $0x0,%eax
80108f13:	eb 0f                	jmp    80108f24 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f18:	8b 00                	mov    (%eax),%eax
80108f1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f1f:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108f24:	c9                   	leave  
80108f25:	c3                   	ret    

80108f26 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108f26:	55                   	push   %ebp
80108f27:	89 e5                	mov    %esp,%ebp
80108f29:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108f2c:	8b 45 10             	mov    0x10(%ebp),%eax
80108f2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108f32:	e9 87 00 00 00       	jmp    80108fbe <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f45:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f49:	8b 45 08             	mov    0x8(%ebp),%eax
80108f4c:	89 04 24             	mov    %eax,(%esp)
80108f4f:	e8 78 ff ff ff       	call   80108ecc <uva2ka>
80108f54:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108f57:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108f5b:	75 07                	jne    80108f64 <copyout+0x3e>
      return -1;
80108f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f62:	eb 69                	jmp    80108fcd <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108f64:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f67:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108f6a:	29 c2                	sub    %eax,%edx
80108f6c:	89 d0                	mov    %edx,%eax
80108f6e:	05 00 10 00 00       	add    $0x1000,%eax
80108f73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f79:	3b 45 14             	cmp    0x14(%ebp),%eax
80108f7c:	76 06                	jbe    80108f84 <copyout+0x5e>
      n = len;
80108f7e:	8b 45 14             	mov    0x14(%ebp),%eax
80108f81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108f84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f87:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f8a:	29 c2                	sub    %eax,%edx
80108f8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f8f:	01 c2                	add    %eax,%edx
80108f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f94:	89 44 24 08          	mov    %eax,0x8(%esp)
80108f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f9f:	89 14 24             	mov    %edx,(%esp)
80108fa2:	e8 44 c8 ff ff       	call   801057eb <memmove>
    len -= n;
80108fa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108faa:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108fad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb0:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108fb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fb6:	05 00 10 00 00       	add    $0x1000,%eax
80108fbb:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108fbe:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108fc2:	0f 85 6f ff ff ff    	jne    80108f37 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108fc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108fcd:	c9                   	leave  
80108fce:	c3                   	ret    
	...

80108fd0 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80108fd0:	55                   	push   %ebp
80108fd1:	89 e5                	mov    %esp,%ebp
80108fd3:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
80108fd6:	8b 45 10             	mov    0x10(%ebp),%eax
80108fd9:	89 44 24 08          	mov    %eax,0x8(%esp)
80108fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80108fe7:	89 04 24             	mov    %eax,(%esp)
80108fea:	e8 fc c7 ff ff       	call   801057eb <memmove>
}
80108fef:	c9                   	leave  
80108ff0:	c3                   	ret    

80108ff1 <strcpy>:

char* strcpy(char *s, char *t){
80108ff1:	55                   	push   %ebp
80108ff2:	89 e5                	mov    %esp,%ebp
80108ff4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80108ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80108ffa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80108ffd:	90                   	nop
80108ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80109001:	8d 50 01             	lea    0x1(%eax),%edx
80109004:	89 55 08             	mov    %edx,0x8(%ebp)
80109007:	8b 55 0c             	mov    0xc(%ebp),%edx
8010900a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010900d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80109010:	8a 12                	mov    (%edx),%dl
80109012:	88 10                	mov    %dl,(%eax)
80109014:	8a 00                	mov    (%eax),%al
80109016:	84 c0                	test   %al,%al
80109018:	75 e4                	jne    80108ffe <strcpy+0xd>
    ;
  return os;
8010901a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010901d:	c9                   	leave  
8010901e:	c3                   	ret    

8010901f <strcmp>:

int
strcmp(const char *p, const char *q)
{
8010901f:	55                   	push   %ebp
80109020:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80109022:	eb 06                	jmp    8010902a <strcmp+0xb>
    p++, q++;
80109024:	ff 45 08             	incl   0x8(%ebp)
80109027:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
8010902a:	8b 45 08             	mov    0x8(%ebp),%eax
8010902d:	8a 00                	mov    (%eax),%al
8010902f:	84 c0                	test   %al,%al
80109031:	74 0e                	je     80109041 <strcmp+0x22>
80109033:	8b 45 08             	mov    0x8(%ebp),%eax
80109036:	8a 10                	mov    (%eax),%dl
80109038:	8b 45 0c             	mov    0xc(%ebp),%eax
8010903b:	8a 00                	mov    (%eax),%al
8010903d:	38 c2                	cmp    %al,%dl
8010903f:	74 e3                	je     80109024 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80109041:	8b 45 08             	mov    0x8(%ebp),%eax
80109044:	8a 00                	mov    (%eax),%al
80109046:	0f b6 d0             	movzbl %al,%edx
80109049:	8b 45 0c             	mov    0xc(%ebp),%eax
8010904c:	8a 00                	mov    (%eax),%al
8010904e:	0f b6 c0             	movzbl %al,%eax
80109051:	29 c2                	sub    %eax,%edx
80109053:	89 d0                	mov    %edx,%eax
}
80109055:	5d                   	pop    %ebp
80109056:	c3                   	ret    

80109057 <set_root_inode>:

// struct con

void set_root_inode(char* name){
80109057:	55                   	push   %ebp
80109058:	89 e5                	mov    %esp,%ebp
8010905a:	53                   	push   %ebx
8010905b:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
8010905e:	8b 45 08             	mov    0x8(%ebp),%eax
80109061:	89 04 24             	mov    %eax,(%esp)
80109064:	e8 02 01 00 00       	call   8010916b <find>
80109069:	89 c3                	mov    %eax,%ebx
8010906b:	8b 45 08             	mov    0x8(%ebp),%eax
8010906e:	89 04 24             	mov    %eax,(%esp)
80109071:	e8 e2 96 ff ff       	call   80102758 <namei>
80109076:	89 c2                	mov    %eax,%edx
80109078:	89 d8                	mov    %ebx,%eax
8010907a:	01 c0                	add    %eax,%eax
8010907c:	01 d8                	add    %ebx,%eax
8010907e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80109085:	01 c8                	add    %ecx,%eax
80109087:	c1 e0 02             	shl    $0x2,%eax
8010908a:	05 10 8c 11 80       	add    $0x80118c10,%eax
8010908f:	89 50 08             	mov    %edx,0x8(%eax)

}
80109092:	83 c4 14             	add    $0x14,%esp
80109095:	5b                   	pop    %ebx
80109096:	5d                   	pop    %ebp
80109097:	c3                   	ret    

80109098 <get_name>:

void get_name(int vc_num, char* name){
80109098:	55                   	push   %ebp
80109099:	89 e5                	mov    %esp,%ebp
8010909b:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
8010909e:	8b 55 08             	mov    0x8(%ebp),%edx
801090a1:	89 d0                	mov    %edx,%eax
801090a3:	01 c0                	add    %eax,%eax
801090a5:	01 d0                	add    %edx,%eax
801090a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090ae:	01 d0                	add    %edx,%eax
801090b0:	c1 e0 02             	shl    $0x2,%eax
801090b3:	83 c0 10             	add    $0x10,%eax
801090b6:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801090bb:	83 c0 08             	add    $0x8,%eax
801090be:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
801090c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
801090c8:	eb 03                	jmp    801090cd <get_name+0x35>
	{
		i++;
801090ca:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
801090cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090d3:	01 d0                	add    %edx,%eax
801090d5:	8a 00                	mov    (%eax),%al
801090d7:	84 c0                	test   %al,%al
801090d9:	75 ef                	jne    801090ca <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
801090db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090de:	89 44 24 08          	mov    %eax,0x8(%esp)
801090e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801090e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801090ec:	89 04 24             	mov    %eax,(%esp)
801090ef:	e8 dc fe ff ff       	call   80108fd0 <memcpy2>
}
801090f4:	c9                   	leave  
801090f5:	c3                   	ret    

801090f6 <g_name>:

char* g_name(int vc_bun){
801090f6:	55                   	push   %ebp
801090f7:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
801090f9:	8b 55 08             	mov    0x8(%ebp),%edx
801090fc:	89 d0                	mov    %edx,%eax
801090fe:	01 c0                	add    %eax,%eax
80109100:	01 d0                	add    %edx,%eax
80109102:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109109:	01 d0                	add    %edx,%eax
8010910b:	c1 e0 02             	shl    $0x2,%eax
8010910e:	83 c0 10             	add    $0x10,%eax
80109111:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109116:	83 c0 08             	add    $0x8,%eax
}
80109119:	5d                   	pop    %ebp
8010911a:	c3                   	ret    

8010911b <is_full>:

int is_full(){
8010911b:	55                   	push   %ebp
8010911c:	89 e5                	mov    %esp,%ebp
8010911e:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109121:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109128:	eb 34                	jmp    8010915e <is_full+0x43>
		if(strlen(containers[i].name) == 0){
8010912a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010912d:	89 d0                	mov    %edx,%eax
8010912f:	01 c0                	add    %eax,%eax
80109131:	01 d0                	add    %edx,%eax
80109133:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010913a:	01 d0                	add    %edx,%eax
8010913c:	c1 e0 02             	shl    $0x2,%eax
8010913f:	83 c0 10             	add    $0x10,%eax
80109142:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109147:	83 c0 08             	add    $0x8,%eax
8010914a:	89 04 24             	mov    %eax,(%esp)
8010914d:	e8 23 c8 ff ff       	call   80105975 <strlen>
80109152:	85 c0                	test   %eax,%eax
80109154:	75 05                	jne    8010915b <is_full+0x40>
			return i;
80109156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109159:	eb 0e                	jmp    80109169 <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010915b:	ff 45 f4             	incl   -0xc(%ebp)
8010915e:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80109162:	7e c6                	jle    8010912a <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80109164:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80109169:	c9                   	leave  
8010916a:	c3                   	ret    

8010916b <find>:

int find(char* name){
8010916b:	55                   	push   %ebp
8010916c:	89 e5                	mov    %esp,%ebp
8010916e:	83 ec 18             	sub    $0x18,%esp
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80109171:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109178:	eb 54                	jmp    801091ce <find+0x63>
		if(strcmp(name, "") == 0){
8010917a:	c7 44 24 04 3c a1 10 	movl   $0x8010a13c,0x4(%esp)
80109181:	80 
80109182:	8b 45 08             	mov    0x8(%ebp),%eax
80109185:	89 04 24             	mov    %eax,(%esp)
80109188:	e8 92 fe ff ff       	call   8010901f <strcmp>
8010918d:	85 c0                	test   %eax,%eax
8010918f:	75 02                	jne    80109193 <find+0x28>
			continue;
80109191:	eb 38                	jmp    801091cb <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
80109193:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109196:	89 d0                	mov    %edx,%eax
80109198:	01 c0                	add    %eax,%eax
8010919a:	01 d0                	add    %edx,%eax
8010919c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091a3:	01 d0                	add    %edx,%eax
801091a5:	c1 e0 02             	shl    $0x2,%eax
801091a8:	83 c0 10             	add    $0x10,%eax
801091ab:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801091b0:	83 c0 08             	add    $0x8,%eax
801091b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801091b7:	8b 45 08             	mov    0x8(%ebp),%eax
801091ba:	89 04 24             	mov    %eax,(%esp)
801091bd:	e8 5d fe ff ff       	call   8010901f <strcmp>
801091c2:	85 c0                	test   %eax,%eax
801091c4:	75 05                	jne    801091cb <find+0x60>
			return i;
801091c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801091c9:	eb 0e                	jmp    801091d9 <find+0x6e>
}

int find(char* name){
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
801091cb:	ff 45 fc             	incl   -0x4(%ebp)
801091ce:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
801091d2:	7e a6                	jle    8010917a <find+0xf>
		}
		if(strcmp(name, containers[i].name) == 0){
			return i;
		}
	}
	return -1;
801091d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801091d9:	c9                   	leave  
801091da:	c3                   	ret    

801091db <get_max_proc>:

int get_max_proc(int vc_num){
801091db:	55                   	push   %ebp
801091dc:	89 e5                	mov    %esp,%ebp
801091de:	57                   	push   %edi
801091df:	56                   	push   %esi
801091e0:	53                   	push   %ebx
801091e1:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801091e4:	8b 55 08             	mov    0x8(%ebp),%edx
801091e7:	89 d0                	mov    %edx,%eax
801091e9:	01 c0                	add    %eax,%eax
801091eb:	01 d0                	add    %edx,%eax
801091ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091f4:	01 d0                	add    %edx,%eax
801091f6:	c1 e0 02             	shl    $0x2,%eax
801091f9:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801091fe:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109201:	89 c3                	mov    %eax,%ebx
80109203:	b8 0f 00 00 00       	mov    $0xf,%eax
80109208:	89 d7                	mov    %edx,%edi
8010920a:	89 de                	mov    %ebx,%esi
8010920c:	89 c1                	mov    %eax,%ecx
8010920e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80109210:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
80109213:	83 c4 40             	add    $0x40,%esp
80109216:	5b                   	pop    %ebx
80109217:	5e                   	pop    %esi
80109218:	5f                   	pop    %edi
80109219:	5d                   	pop    %ebp
8010921a:	c3                   	ret    

8010921b <get_container>:

struct container* get_container(int vc_num){
8010921b:	55                   	push   %ebp
8010921c:	89 e5                	mov    %esp,%ebp
8010921e:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80109221:	8b 55 08             	mov    0x8(%ebp),%edx
80109224:	89 d0                	mov    %edx,%eax
80109226:	01 c0                	add    %eax,%eax
80109228:	01 d0                	add    %edx,%eax
8010922a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109231:	01 d0                	add    %edx,%eax
80109233:	c1 e0 02             	shl    $0x2,%eax
80109236:	05 e0 8b 11 80       	add    $0x80118be0,%eax
8010923b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return cont;
8010923e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109241:	c9                   	leave  
80109242:	c3                   	ret    

80109243 <get_max_mem>:

int get_max_mem(int vc_num){
80109243:	55                   	push   %ebp
80109244:	89 e5                	mov    %esp,%ebp
80109246:	57                   	push   %edi
80109247:	56                   	push   %esi
80109248:	53                   	push   %ebx
80109249:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010924c:	8b 55 08             	mov    0x8(%ebp),%edx
8010924f:	89 d0                	mov    %edx,%eax
80109251:	01 c0                	add    %eax,%eax
80109253:	01 d0                	add    %edx,%eax
80109255:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010925c:	01 d0                	add    %edx,%eax
8010925e:	c1 e0 02             	shl    $0x2,%eax
80109261:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109266:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109269:	89 c3                	mov    %eax,%ebx
8010926b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109270:	89 d7                	mov    %edx,%edi
80109272:	89 de                	mov    %ebx,%esi
80109274:	89 c1                	mov    %eax,%ecx
80109276:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80109278:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
8010927b:	83 c4 40             	add    $0x40,%esp
8010927e:	5b                   	pop    %ebx
8010927f:	5e                   	pop    %esi
80109280:	5f                   	pop    %edi
80109281:	5d                   	pop    %ebp
80109282:	c3                   	ret    

80109283 <get_max_disk>:

int get_max_disk(int vc_num){
80109283:	55                   	push   %ebp
80109284:	89 e5                	mov    %esp,%ebp
80109286:	57                   	push   %edi
80109287:	56                   	push   %esi
80109288:	53                   	push   %ebx
80109289:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010928c:	8b 55 08             	mov    0x8(%ebp),%edx
8010928f:	89 d0                	mov    %edx,%eax
80109291:	01 c0                	add    %eax,%eax
80109293:	01 d0                	add    %edx,%eax
80109295:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010929c:	01 d0                	add    %edx,%eax
8010929e:	c1 e0 02             	shl    $0x2,%eax
801092a1:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801092a6:	8d 55 b8             	lea    -0x48(%ebp),%edx
801092a9:	89 c3                	mov    %eax,%ebx
801092ab:	b8 0f 00 00 00       	mov    $0xf,%eax
801092b0:	89 d7                	mov    %edx,%edi
801092b2:	89 de                	mov    %ebx,%esi
801092b4:	89 c1                	mov    %eax,%ecx
801092b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
801092b8:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
801092bb:	83 c4 40             	add    $0x40,%esp
801092be:	5b                   	pop    %ebx
801092bf:	5e                   	pop    %esi
801092c0:	5f                   	pop    %edi
801092c1:	5d                   	pop    %ebp
801092c2:	c3                   	ret    

801092c3 <get_curr_proc>:

int get_curr_proc(int vc_num){
801092c3:	55                   	push   %ebp
801092c4:	89 e5                	mov    %esp,%ebp
801092c6:	57                   	push   %edi
801092c7:	56                   	push   %esi
801092c8:	53                   	push   %ebx
801092c9:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801092cc:	8b 55 08             	mov    0x8(%ebp),%edx
801092cf:	89 d0                	mov    %edx,%eax
801092d1:	01 c0                	add    %eax,%eax
801092d3:	01 d0                	add    %edx,%eax
801092d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092dc:	01 d0                	add    %edx,%eax
801092de:	c1 e0 02             	shl    $0x2,%eax
801092e1:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801092e6:	8d 55 b8             	lea    -0x48(%ebp),%edx
801092e9:	89 c3                	mov    %eax,%ebx
801092eb:	b8 0f 00 00 00       	mov    $0xf,%eax
801092f0:	89 d7                	mov    %edx,%edi
801092f2:	89 de                	mov    %ebx,%esi
801092f4:	89 c1                	mov    %eax,%ecx
801092f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
801092f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
801092fb:	83 c4 40             	add    $0x40,%esp
801092fe:	5b                   	pop    %ebx
801092ff:	5e                   	pop    %esi
80109300:	5f                   	pop    %edi
80109301:	5d                   	pop    %ebp
80109302:	c3                   	ret    

80109303 <get_curr_mem>:

int get_curr_mem(int vc_num){
80109303:	55                   	push   %ebp
80109304:	89 e5                	mov    %esp,%ebp
80109306:	57                   	push   %edi
80109307:	56                   	push   %esi
80109308:	53                   	push   %ebx
80109309:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010930c:	8b 55 08             	mov    0x8(%ebp),%edx
8010930f:	89 d0                	mov    %edx,%eax
80109311:	01 c0                	add    %eax,%eax
80109313:	01 d0                	add    %edx,%eax
80109315:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010931c:	01 d0                	add    %edx,%eax
8010931e:	c1 e0 02             	shl    $0x2,%eax
80109321:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109326:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109329:	89 c3                	mov    %eax,%ebx
8010932b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109330:	89 d7                	mov    %edx,%edi
80109332:	89 de                	mov    %ebx,%esi
80109334:	89 c1                	mov    %eax,%ecx
80109336:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
	return x.curr_mem; 
80109338:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
8010933b:	83 c4 40             	add    $0x40,%esp
8010933e:	5b                   	pop    %ebx
8010933f:	5e                   	pop    %esi
80109340:	5f                   	pop    %edi
80109341:	5d                   	pop    %ebp
80109342:	c3                   	ret    

80109343 <get_curr_disk>:

int get_curr_disk(int vc_num){
80109343:	55                   	push   %ebp
80109344:	89 e5                	mov    %esp,%ebp
80109346:	57                   	push   %edi
80109347:	56                   	push   %esi
80109348:	53                   	push   %ebx
80109349:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010934c:	8b 55 08             	mov    0x8(%ebp),%edx
8010934f:	89 d0                	mov    %edx,%eax
80109351:	01 c0                	add    %eax,%eax
80109353:	01 d0                	add    %edx,%eax
80109355:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010935c:	01 d0                	add    %edx,%eax
8010935e:	c1 e0 02             	shl    $0x2,%eax
80109361:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109366:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109369:	89 c3                	mov    %eax,%ebx
8010936b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109370:	89 d7                	mov    %edx,%edi
80109372:	89 de                	mov    %ebx,%esi
80109374:	89 c1                	mov    %eax,%ecx
80109376:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80109378:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
8010937b:	83 c4 40             	add    $0x40,%esp
8010937e:	5b                   	pop    %ebx
8010937f:	5e                   	pop    %esi
80109380:	5f                   	pop    %edi
80109381:	5d                   	pop    %ebp
80109382:	c3                   	ret    

80109383 <set_name>:

void set_name(char* name, int vc_num){
80109383:	55                   	push   %ebp
80109384:	89 e5                	mov    %esp,%ebp
80109386:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80109389:	8b 55 0c             	mov    0xc(%ebp),%edx
8010938c:	89 d0                	mov    %edx,%eax
8010938e:	01 c0                	add    %eax,%eax
80109390:	01 d0                	add    %edx,%eax
80109392:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109399:	01 d0                	add    %edx,%eax
8010939b:	c1 e0 02             	shl    $0x2,%eax
8010939e:	83 c0 10             	add    $0x10,%eax
801093a1:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801093a6:	8d 50 08             	lea    0x8(%eax),%edx
801093a9:	8b 45 08             	mov    0x8(%ebp),%eax
801093ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801093b0:	89 14 24             	mov    %edx,(%esp)
801093b3:	e8 39 fc ff ff       	call   80108ff1 <strcpy>
}
801093b8:	c9                   	leave  
801093b9:	c3                   	ret    

801093ba <set_max_mem>:

void set_max_mem(int mem, int vc_num){
801093ba:	55                   	push   %ebp
801093bb:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
801093bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801093c0:	89 d0                	mov    %edx,%eax
801093c2:	01 c0                	add    %eax,%eax
801093c4:	01 d0                	add    %edx,%eax
801093c6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093cd:	01 d0                	add    %edx,%eax
801093cf:	c1 e0 02             	shl    $0x2,%eax
801093d2:	8d 90 e0 8b 11 80    	lea    -0x7fee7420(%eax),%edx
801093d8:	8b 45 08             	mov    0x8(%ebp),%eax
801093db:	89 02                	mov    %eax,(%edx)
}
801093dd:	5d                   	pop    %ebp
801093de:	c3                   	ret    

801093df <set_max_disk>:

void set_max_disk(int disk, int vc_num){
801093df:	55                   	push   %ebp
801093e0:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
801093e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801093e5:	89 d0                	mov    %edx,%eax
801093e7:	01 c0                	add    %eax,%eax
801093e9:	01 d0                	add    %edx,%eax
801093eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093f2:	01 d0                	add    %edx,%eax
801093f4:	c1 e0 02             	shl    $0x2,%eax
801093f7:	8d 90 e0 8b 11 80    	lea    -0x7fee7420(%eax),%edx
801093fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109400:	89 42 08             	mov    %eax,0x8(%edx)
}
80109403:	5d                   	pop    %ebp
80109404:	c3                   	ret    

80109405 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
80109405:	55                   	push   %ebp
80109406:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80109408:	8b 55 0c             	mov    0xc(%ebp),%edx
8010940b:	89 d0                	mov    %edx,%eax
8010940d:	01 c0                	add    %eax,%eax
8010940f:	01 d0                	add    %edx,%eax
80109411:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109418:	01 d0                	add    %edx,%eax
8010941a:	c1 e0 02             	shl    $0x2,%eax
8010941d:	8d 90 e0 8b 11 80    	lea    -0x7fee7420(%eax),%edx
80109423:	8b 45 08             	mov    0x8(%ebp),%eax
80109426:	89 42 04             	mov    %eax,0x4(%edx)
}
80109429:	5d                   	pop    %ebp
8010942a:	c3                   	ret    

8010942b <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
8010942b:	55                   	push   %ebp
8010942c:	89 e5                	mov    %esp,%ebp
8010942e:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_mem + 1) > containers[vc_num].max_mem){
80109431:	8b 55 0c             	mov    0xc(%ebp),%edx
80109434:	89 d0                	mov    %edx,%eax
80109436:	01 c0                	add    %eax,%eax
80109438:	01 d0                	add    %edx,%eax
8010943a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109441:	01 d0                	add    %edx,%eax
80109443:	c1 e0 02             	shl    $0x2,%eax
80109446:	05 e0 8b 11 80       	add    $0x80118be0,%eax
8010944b:	8b 40 0c             	mov    0xc(%eax),%eax
8010944e:	8d 48 01             	lea    0x1(%eax),%ecx
80109451:	8b 55 0c             	mov    0xc(%ebp),%edx
80109454:	89 d0                	mov    %edx,%eax
80109456:	01 c0                	add    %eax,%eax
80109458:	01 d0                	add    %edx,%eax
8010945a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109461:	01 d0                	add    %edx,%eax
80109463:	c1 e0 02             	shl    $0x2,%eax
80109466:	05 e0 8b 11 80       	add    $0x80118be0,%eax
8010946b:	8b 00                	mov    (%eax),%eax
8010946d:	39 c1                	cmp    %eax,%ecx
8010946f:	7e 0e                	jle    8010947f <set_curr_mem+0x54>
		cprintf("Exceded memory resource; killing container");
80109471:	c7 04 24 40 a1 10 80 	movl   $0x8010a140,(%esp)
80109478:	e8 44 6f ff ff       	call   801003c1 <cprintf>
8010947d:	eb 3d                	jmp    801094bc <set_curr_mem+0x91>
	}
	else{
		containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
8010947f:	8b 55 0c             	mov    0xc(%ebp),%edx
80109482:	89 d0                	mov    %edx,%eax
80109484:	01 c0                	add    %eax,%eax
80109486:	01 d0                	add    %edx,%eax
80109488:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010948f:	01 d0                	add    %edx,%eax
80109491:	c1 e0 02             	shl    $0x2,%eax
80109494:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109499:	8b 40 0c             	mov    0xc(%eax),%eax
8010949c:	8d 48 01             	lea    0x1(%eax),%ecx
8010949f:	8b 55 0c             	mov    0xc(%ebp),%edx
801094a2:	89 d0                	mov    %edx,%eax
801094a4:	01 c0                	add    %eax,%eax
801094a6:	01 d0                	add    %edx,%eax
801094a8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094af:	01 d0                	add    %edx,%eax
801094b1:	c1 e0 02             	shl    $0x2,%eax
801094b4:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801094b9:	89 48 0c             	mov    %ecx,0xc(%eax)
	}
}
801094bc:	c9                   	leave  
801094bd:	c3                   	ret    

801094be <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
801094be:	55                   	push   %ebp
801094bf:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;	
801094c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801094c4:	89 d0                	mov    %edx,%eax
801094c6:	01 c0                	add    %eax,%eax
801094c8:	01 d0                	add    %edx,%eax
801094ca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094d1:	01 d0                	add    %edx,%eax
801094d3:	c1 e0 02             	shl    $0x2,%eax
801094d6:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801094db:	8b 40 0c             	mov    0xc(%eax),%eax
801094de:	8d 48 ff             	lea    -0x1(%eax),%ecx
801094e1:	8b 55 0c             	mov    0xc(%ebp),%edx
801094e4:	89 d0                	mov    %edx,%eax
801094e6:	01 c0                	add    %eax,%eax
801094e8:	01 d0                	add    %edx,%eax
801094ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094f1:	01 d0                	add    %edx,%eax
801094f3:	c1 e0 02             	shl    $0x2,%eax
801094f6:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801094fb:	89 48 0c             	mov    %ecx,0xc(%eax)
}
801094fe:	5d                   	pop    %ebp
801094ff:	c3                   	ret    

80109500 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
80109500:	55                   	push   %ebp
80109501:	89 e5                	mov    %esp,%ebp
80109503:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_disk + disk)/1024 > containers[vc_num].max_disk){
80109506:	8b 55 0c             	mov    0xc(%ebp),%edx
80109509:	89 d0                	mov    %edx,%eax
8010950b:	01 c0                	add    %eax,%eax
8010950d:	01 d0                	add    %edx,%eax
8010950f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109516:	01 d0                	add    %edx,%eax
80109518:	c1 e0 02             	shl    $0x2,%eax
8010951b:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
80109520:	8b 50 04             	mov    0x4(%eax),%edx
80109523:	8b 45 08             	mov    0x8(%ebp),%eax
80109526:	01 d0                	add    %edx,%eax
80109528:	85 c0                	test   %eax,%eax
8010952a:	79 05                	jns    80109531 <set_curr_disk+0x31>
8010952c:	05 ff 03 00 00       	add    $0x3ff,%eax
80109531:	c1 f8 0a             	sar    $0xa,%eax
80109534:	89 c1                	mov    %eax,%ecx
80109536:	8b 55 0c             	mov    0xc(%ebp),%edx
80109539:	89 d0                	mov    %edx,%eax
8010953b:	01 c0                	add    %eax,%eax
8010953d:	01 d0                	add    %edx,%eax
8010953f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109546:	01 d0                	add    %edx,%eax
80109548:	c1 e0 02             	shl    $0x2,%eax
8010954b:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109550:	8b 40 08             	mov    0x8(%eax),%eax
80109553:	39 c1                	cmp    %eax,%ecx
80109555:	7e 0e                	jle    80109565 <set_curr_disk+0x65>
		cprintf("Exceded disk resource; killing container");
80109557:	c7 04 24 6c a1 10 80 	movl   $0x8010a16c,(%esp)
8010955e:	e8 5e 6e ff ff       	call   801003c1 <cprintf>
80109563:	eb 40                	jmp    801095a5 <set_curr_disk+0xa5>
	}
	else{
		containers[vc_num].curr_disk += disk;
80109565:	8b 55 0c             	mov    0xc(%ebp),%edx
80109568:	89 d0                	mov    %edx,%eax
8010956a:	01 c0                	add    %eax,%eax
8010956c:	01 d0                	add    %edx,%eax
8010956e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109575:	01 d0                	add    %edx,%eax
80109577:	c1 e0 02             	shl    $0x2,%eax
8010957a:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
8010957f:	8b 50 04             	mov    0x4(%eax),%edx
80109582:	8b 45 08             	mov    0x8(%ebp),%eax
80109585:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109588:	8b 55 0c             	mov    0xc(%ebp),%edx
8010958b:	89 d0                	mov    %edx,%eax
8010958d:	01 c0                	add    %eax,%eax
8010958f:	01 d0                	add    %edx,%eax
80109591:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109598:	01 d0                	add    %edx,%eax
8010959a:	c1 e0 02             	shl    $0x2,%eax
8010959d:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
801095a2:	89 48 04             	mov    %ecx,0x4(%eax)
	}
}
801095a5:	c9                   	leave  
801095a6:	c3                   	ret    

801095a7 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
801095a7:	55                   	push   %ebp
801095a8:	89 e5                	mov    %esp,%ebp
801095aa:	83 ec 18             	sub    $0x18,%esp
	if(containers[vc_num].curr_proc + procs > containers[vc_num].max_proc){
801095ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801095b0:	89 d0                	mov    %edx,%eax
801095b2:	01 c0                	add    %eax,%eax
801095b4:	01 d0                	add    %edx,%eax
801095b6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095bd:	01 d0                	add    %edx,%eax
801095bf:	c1 e0 02             	shl    $0x2,%eax
801095c2:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
801095c7:	8b 10                	mov    (%eax),%edx
801095c9:	8b 45 08             	mov    0x8(%ebp),%eax
801095cc:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801095cf:	8b 55 0c             	mov    0xc(%ebp),%edx
801095d2:	89 d0                	mov    %edx,%eax
801095d4:	01 c0                	add    %eax,%eax
801095d6:	01 d0                	add    %edx,%eax
801095d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095df:	01 d0                	add    %edx,%eax
801095e1:	c1 e0 02             	shl    $0x2,%eax
801095e4:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801095e9:	8b 40 04             	mov    0x4(%eax),%eax
801095ec:	39 c1                	cmp    %eax,%ecx
801095ee:	7e 60                	jle    80109650 <set_curr_proc+0xa9>
		
		cprintf("Curr: %d  Max:  %d", containers[vc_num].curr_proc + procs, containers[vc_num].max_proc);
801095f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801095f3:	89 d0                	mov    %edx,%eax
801095f5:	01 c0                	add    %eax,%eax
801095f7:	01 d0                	add    %edx,%eax
801095f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109600:	01 d0                	add    %edx,%eax
80109602:	c1 e0 02             	shl    $0x2,%eax
80109605:	05 e0 8b 11 80       	add    $0x80118be0,%eax
8010960a:	8b 50 04             	mov    0x4(%eax),%edx
8010960d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80109610:	89 c8                	mov    %ecx,%eax
80109612:	01 c0                	add    %eax,%eax
80109614:	01 c8                	add    %ecx,%eax
80109616:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
8010961d:	01 c8                	add    %ecx,%eax
8010961f:	c1 e0 02             	shl    $0x2,%eax
80109622:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
80109627:	8b 08                	mov    (%eax),%ecx
80109629:	8b 45 08             	mov    0x8(%ebp),%eax
8010962c:	01 c8                	add    %ecx,%eax
8010962e:	89 54 24 08          	mov    %edx,0x8(%esp)
80109632:	89 44 24 04          	mov    %eax,0x4(%esp)
80109636:	c7 04 24 95 a1 10 80 	movl   $0x8010a195,(%esp)
8010963d:	e8 7f 6d ff ff       	call   801003c1 <cprintf>
		cprintf("Exceded procs resource; killing container");
80109642:	c7 04 24 a8 a1 10 80 	movl   $0x8010a1a8,(%esp)
80109649:	e8 73 6d ff ff       	call   801003c1 <cprintf>
8010964e:	eb 3e                	jmp    8010968e <set_curr_proc+0xe7>
	}
	else{
		containers[vc_num].curr_proc += procs;
80109650:	8b 55 0c             	mov    0xc(%ebp),%edx
80109653:	89 d0                	mov    %edx,%eax
80109655:	01 c0                	add    %eax,%eax
80109657:	01 d0                	add    %edx,%eax
80109659:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109660:	01 d0                	add    %edx,%eax
80109662:	c1 e0 02             	shl    $0x2,%eax
80109665:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
8010966a:	8b 10                	mov    (%eax),%edx
8010966c:	8b 45 08             	mov    0x8(%ebp),%eax
8010966f:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109672:	8b 55 0c             	mov    0xc(%ebp),%edx
80109675:	89 d0                	mov    %edx,%eax
80109677:	01 c0                	add    %eax,%eax
80109679:	01 d0                	add    %edx,%eax
8010967b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109682:	01 d0                	add    %edx,%eax
80109684:	c1 e0 02             	shl    $0x2,%eax
80109687:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
8010968c:	89 08                	mov    %ecx,(%eax)
	}
}
8010968e:	c9                   	leave  
8010968f:	c3                   	ret    

80109690 <max_containers>:

int max_containers(){
80109690:	55                   	push   %ebp
80109691:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
80109693:	b8 04 00 00 00       	mov    $0x4,%eax
}
80109698:	5d                   	pop    %ebp
80109699:	c3                   	ret    

8010969a <container_init>:

void container_init(){
8010969a:	55                   	push   %ebp
8010969b:	89 e5                	mov    %esp,%ebp
8010969d:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801096a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801096a7:	e9 f7 00 00 00       	jmp    801097a3 <container_init+0x109>
		strcpy(containers[i].name, "");
801096ac:	8b 55 fc             	mov    -0x4(%ebp),%edx
801096af:	89 d0                	mov    %edx,%eax
801096b1:	01 c0                	add    %eax,%eax
801096b3:	01 d0                	add    %edx,%eax
801096b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096bc:	01 d0                	add    %edx,%eax
801096be:	c1 e0 02             	shl    $0x2,%eax
801096c1:	83 c0 10             	add    $0x10,%eax
801096c4:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801096c9:	83 c0 08             	add    $0x8,%eax
801096cc:	c7 44 24 04 3c a1 10 	movl   $0x8010a13c,0x4(%esp)
801096d3:	80 
801096d4:	89 04 24             	mov    %eax,(%esp)
801096d7:	e8 15 f9 ff ff       	call   80108ff1 <strcpy>
		containers[i].max_proc = 4;
801096dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801096df:	89 d0                	mov    %edx,%eax
801096e1:	01 c0                	add    %eax,%eax
801096e3:	01 d0                	add    %edx,%eax
801096e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096ec:	01 d0                	add    %edx,%eax
801096ee:	c1 e0 02             	shl    $0x2,%eax
801096f1:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801096f6:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
801096fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109700:	89 d0                	mov    %edx,%eax
80109702:	01 c0                	add    %eax,%eax
80109704:	01 d0                	add    %edx,%eax
80109706:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010970d:	01 d0                	add    %edx,%eax
8010970f:	c1 e0 02             	shl    $0x2,%eax
80109712:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109717:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 300;
8010971e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109721:	89 d0                	mov    %edx,%eax
80109723:	01 c0                	add    %eax,%eax
80109725:	01 d0                	add    %edx,%eax
80109727:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010972e:	01 d0                	add    %edx,%eax
80109730:	c1 e0 02             	shl    $0x2,%eax
80109733:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109738:	c7 00 2c 01 00 00    	movl   $0x12c,(%eax)
		containers[i].curr_proc = 0;
8010973e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109741:	89 d0                	mov    %edx,%eax
80109743:	01 c0                	add    %eax,%eax
80109745:	01 d0                	add    %edx,%eax
80109747:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010974e:	01 d0                	add    %edx,%eax
80109750:	c1 e0 02             	shl    $0x2,%eax
80109753:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
80109758:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		containers[i].curr_disk = 0;
8010975e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109761:	89 d0                	mov    %edx,%eax
80109763:	01 c0                	add    %eax,%eax
80109765:	01 d0                	add    %edx,%eax
80109767:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010976e:	01 d0                	add    %edx,%eax
80109770:	c1 e0 02             	shl    $0x2,%eax
80109773:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
80109778:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
8010977f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109782:	89 d0                	mov    %edx,%eax
80109784:	01 c0                	add    %eax,%eax
80109786:	01 d0                	add    %edx,%eax
80109788:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010978f:	01 d0                	add    %edx,%eax
80109791:	c1 e0 02             	shl    $0x2,%eax
80109794:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109799:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	return MAX_CONTAINERS;
}

void container_init(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801097a0:	ff 45 fc             	incl   -0x4(%ebp)
801097a3:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
801097a7:	0f 8e ff fe ff ff    	jle    801096ac <container_init+0x12>
		containers[i].max_mem = 300;
		containers[i].curr_proc = 0;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
801097ad:	c9                   	leave  
801097ae:	c3                   	ret    

801097af <container_reset>:

void container_reset(int vc_num){
801097af:	55                   	push   %ebp
801097b0:	89 e5                	mov    %esp,%ebp
801097b2:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, "");
801097b5:	8b 55 08             	mov    0x8(%ebp),%edx
801097b8:	89 d0                	mov    %edx,%eax
801097ba:	01 c0                	add    %eax,%eax
801097bc:	01 d0                	add    %edx,%eax
801097be:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097c5:	01 d0                	add    %edx,%eax
801097c7:	c1 e0 02             	shl    $0x2,%eax
801097ca:	83 c0 10             	add    $0x10,%eax
801097cd:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801097d2:	83 c0 08             	add    $0x8,%eax
801097d5:	c7 44 24 04 3c a1 10 	movl   $0x8010a13c,0x4(%esp)
801097dc:	80 
801097dd:	89 04 24             	mov    %eax,(%esp)
801097e0:	e8 0c f8 ff ff       	call   80108ff1 <strcpy>
	containers[vc_num].max_proc = 4;
801097e5:	8b 55 08             	mov    0x8(%ebp),%edx
801097e8:	89 d0                	mov    %edx,%eax
801097ea:	01 c0                	add    %eax,%eax
801097ec:	01 d0                	add    %edx,%eax
801097ee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097f5:	01 d0                	add    %edx,%eax
801097f7:	c1 e0 02             	shl    $0x2,%eax
801097fa:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801097ff:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
	containers[vc_num].max_disk = 100;
80109806:	8b 55 08             	mov    0x8(%ebp),%edx
80109809:	89 d0                	mov    %edx,%eax
8010980b:	01 c0                	add    %eax,%eax
8010980d:	01 d0                	add    %edx,%eax
8010980f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109816:	01 d0                	add    %edx,%eax
80109818:	c1 e0 02             	shl    $0x2,%eax
8010981b:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109820:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
	containers[vc_num].max_mem = 200;
80109827:	8b 55 08             	mov    0x8(%ebp),%edx
8010982a:	89 d0                	mov    %edx,%eax
8010982c:	01 c0                	add    %eax,%eax
8010982e:	01 d0                	add    %edx,%eax
80109830:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109837:	01 d0                	add    %edx,%eax
80109839:	c1 e0 02             	shl    $0x2,%eax
8010983c:	05 e0 8b 11 80       	add    $0x80118be0,%eax
80109841:	c7 00 c8 00 00 00    	movl   $0xc8,(%eax)
	containers[vc_num].curr_proc = 0;
80109847:	8b 55 08             	mov    0x8(%ebp),%edx
8010984a:	89 d0                	mov    %edx,%eax
8010984c:	01 c0                	add    %eax,%eax
8010984e:	01 d0                	add    %edx,%eax
80109850:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109857:	01 d0                	add    %edx,%eax
80109859:	c1 e0 02             	shl    $0x2,%eax
8010985c:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
80109861:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	containers[vc_num].curr_disk = 0;
80109867:	8b 55 08             	mov    0x8(%ebp),%edx
8010986a:	89 d0                	mov    %edx,%eax
8010986c:	01 c0                	add    %eax,%eax
8010986e:	01 d0                	add    %edx,%eax
80109870:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109877:	01 d0                	add    %edx,%eax
80109879:	c1 e0 02             	shl    $0x2,%eax
8010987c:	05 f0 8b 11 80       	add    $0x80118bf0,%eax
80109881:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	containers[vc_num].curr_mem = 0;
80109888:	8b 55 08             	mov    0x8(%ebp),%edx
8010988b:	89 d0                	mov    %edx,%eax
8010988d:	01 c0                	add    %eax,%eax
8010988f:	01 d0                	add    %edx,%eax
80109891:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109898:	01 d0                	add    %edx,%eax
8010989a:	c1 e0 02             	shl    $0x2,%eax
8010989d:	05 e0 8b 11 80       	add    $0x80118be0,%eax
801098a2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
801098a9:	c9                   	leave  
801098aa:	c3                   	ret    
