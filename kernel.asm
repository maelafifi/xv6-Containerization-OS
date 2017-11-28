
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
8010002d:	b8 f6 38 10 80       	mov    $0x801038f6,%eax
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
8010003a:	c7 44 24 04 ec 8a 10 	movl   $0x80108aec,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100049:	e8 b8 4e 00 00       	call   80104f06 <initlock>

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
80100087:	c7 44 24 04 f3 8a 10 	movl   $0x80108af3,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 31 4d 00 00       	call   80104dc8 <initsleeplock>
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
801000c9:	e8 59 4e 00 00       	call   80104f27 <acquire>

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
80100104:	e8 88 4e 00 00       	call   80104f91 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 eb 4c 00 00       	call   80104e02 <acquiresleep>
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
8010017d:	e8 0f 4e 00 00       	call   80104f91 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 72 4c 00 00       	call   80104e02 <acquiresleep>
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
801001a7:	c7 04 24 fa 8a 10 80 	movl   $0x80108afa,(%esp)
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
801001e2:	e8 46 28 00 00       	call   80102a2d <iderw>
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
801001fb:	e8 9f 4c 00 00       	call   80104e9f <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 0b 8b 10 80 	movl   $0x80108b0b,(%esp)
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
80100225:	e8 03 28 00 00       	call   80102a2d <iderw>
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
8010023b:	e8 5f 4c 00 00       	call   80104e9f <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 12 8b 10 80 	movl   $0x80108b12,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 ff 4b 00 00       	call   80104e5d <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80100265:	e8 bd 4c 00 00       	call   80104f27 <acquire>
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
801002d1:	e8 bb 4c 00 00       	call   80104f91 <release>
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
801003dc:	e8 46 4b 00 00       	call   80104f27 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 19 8b 10 80 	movl   $0x80108b19,(%esp)
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
801004cf:	c7 45 ec 22 8b 10 80 	movl   $0x80108b22,-0x14(%ebp)
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
8010054d:	e8 3f 4a 00 00       	call   80104f91 <release>
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
80100569:	e8 5b 2b 00 00       	call   801030c9 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 29 8b 10 80 	movl   $0x80108b29,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 3d 8b 10 80 	movl   $0x80108b3d,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 37 4a 00 00       	call   80104fde <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 3f 8b 10 80 	movl   $0x80108b3f,(%esp)
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
80100695:	c7 04 24 43 8b 10 80 	movl   $0x80108b43,(%esp)
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
801006c9:	e8 85 4b 00 00       	call   80105253 <memmove>
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
801006f8:	e8 8d 4a 00 00       	call   8010518a <memset>
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
8010078e:	e8 25 66 00 00       	call   80106db8 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 19 66 00 00       	call   80106db8 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 0d 66 00 00       	call   80106db8 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 00 66 00 00       	call   80106db8 <uartputc>
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
80100813:	e8 0f 47 00 00       	call   80104f27 <acquire>
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
80100a00:	e8 28 42 00 00       	call   80104c2d <wakeup>
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
80100a21:	e8 6b 45 00 00       	call   80104f91 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 05                	je     80100a31 <consoleintr+0x23c>
    procdump();  // now call procdump() wo. cons.lock held
80100a2c:	e8 9f 42 00 00       	call   80104cd0 <procdump>
  }
  if(doconsoleswitch){
80100a31:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a35:	74 15                	je     80100a4c <consoleintr+0x257>
    cprintf("\nActive console now: %d\n", active);
80100a37:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a40:	c7 04 24 56 8b 10 80 	movl   $0x80108b56,(%esp)
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
80100a60:	e8 bf 11 00 00       	call   80101c24 <iunlock>
  target = n;
80100a65:	8b 45 10             	mov    0x10(%ebp),%eax
80100a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6b:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100a72:	e8 b0 44 00 00       	call   80104f27 <acquire>
  while(n > 0){
80100a77:	e9 b7 00 00 00       	jmp    80100b33 <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a7c:	eb 41                	jmp    80100abf <consoleread+0x6b>
      if(myproc()->killed){
80100a7e:	e8 88 38 00 00       	call   8010430b <myproc>
80100a83:	8b 40 24             	mov    0x24(%eax),%eax
80100a86:	85 c0                	test   %eax,%eax
80100a88:	74 21                	je     80100aab <consoleread+0x57>
        release(&cons.lock);
80100a8a:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100a91:	e8 fb 44 00 00       	call   80104f91 <release>
        ilock(ip);
80100a96:	8b 45 08             	mov    0x8(%ebp),%eax
80100a99:	89 04 24             	mov    %eax,(%esp)
80100a9c:	e8 79 10 00 00       	call   80101b1a <ilock>
        return -1;
80100aa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100aa6:	e9 b3 00 00 00       	jmp    80100b5e <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100aab:	c7 44 24 04 40 c8 10 	movl   $0x8010c840,0x4(%esp)
80100ab2:	80 
80100ab3:	c7 04 24 c0 22 11 80 	movl   $0x801122c0,(%esp)
80100aba:	e8 9a 40 00 00       	call   80104b59 <sleep>

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
80100b44:	e8 48 44 00 00       	call   80104f91 <release>
  ilock(ip);
80100b49:	8b 45 08             	mov    0x8(%ebp),%eax
80100b4c:	89 04 24             	mov    %eax,(%esp)
80100b4f:	e8 c6 0f 00 00       	call   80101b1a <ilock>

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
80100b7e:	e8 a1 10 00 00       	call   80101c24 <iunlock>
    acquire(&cons.lock);
80100b83:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100b8a:	e8 98 43 00 00       	call   80104f27 <acquire>
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
80100bc2:	e8 ca 43 00 00       	call   80104f91 <release>
    ilock(ip);
80100bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80100bca:	89 04 24             	mov    %eax,(%esp)
80100bcd:	e8 48 0f 00 00       	call   80101b1a <ilock>
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
80100bdd:	c7 44 24 04 6f 8b 10 	movl   $0x80108b6f,0x4(%esp)
80100be4:	80 
80100be5:	c7 04 24 40 c8 10 80 	movl   $0x8010c840,(%esp)
80100bec:	e8 15 43 00 00       	call   80104f06 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100bf1:	c7 05 2c 2e 11 80 60 	movl   $0x80100b60,0x80112e2c
80100bf8:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bfb:	c7 05 28 2e 11 80 54 	movl   $0x80100a54,0x80112e28
80100c02:	0a 10 80 
  cons.locking = 1;
80100c05:	c7 05 74 c8 10 80 01 	movl   $0x1,0x8010c874
80100c0c:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c16:	00 
80100c17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c1e:	e8 bc 1f 00 00       	call   80102bdf <ioapicenable>
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
80100c31:	e8 d5 36 00 00       	call   8010430b <myproc>
80100c36:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c39:	e8 d5 29 00 00       	call   80103613 <begin_op>

  if((ip = namei(path)) == 0){
80100c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80100c41:	89 04 24             	mov    %eax,(%esp)
80100c44:	e8 f6 19 00 00       	call   8010263f <namei>
80100c49:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c4c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c50:	75 1b                	jne    80100c6d <exec+0x45>
    end_op();
80100c52:	e8 3e 2a 00 00       	call   80103695 <end_op>
    cprintf("exec: fail\n");
80100c57:	c7 04 24 77 8b 10 80 	movl   $0x80108b77,(%esp)
80100c5e:	e8 5e f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100c63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c68:	e9 f6 03 00 00       	jmp    80101063 <exec+0x43b>
  }
  ilock(ip);
80100c6d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c70:	89 04 24             	mov    %eax,(%esp)
80100c73:	e8 a2 0e 00 00       	call   80101b1a <ilock>
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
80100c9f:	e8 0d 13 00 00       	call   80101fb1 <readi>
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
80100cc0:	e8 d5 70 00 00       	call   80107d9a <setupkvm>
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
80100d0e:	e8 9e 12 00 00       	call   80101fb1 <readi>
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
80100d7e:	e8 e3 73 00 00       	call   80108166 <allocuvm>
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
80100dd0:	e8 ae 72 00 00       	call   80108083 <loaduvm>
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
80100e02:	e8 12 0f 00 00       	call   80101d19 <iunlockput>
  end_op();
80100e07:	e8 89 28 00 00       	call   80103695 <end_op>
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
80100e3c:	e8 25 73 00 00       	call   80108166 <allocuvm>
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
80100e61:	e8 70 75 00 00       	call   801083d6 <clearpteu>
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
80100e97:	e8 41 45 00 00       	call   801053dd <strlen>
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
80100ebe:	e8 1a 45 00 00       	call   801053dd <strlen>
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
80100eec:	e8 9d 76 00 00       	call   8010858e <copyout>
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
80100f90:	e8 f9 75 00 00       	call   8010858e <copyout>
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
80100fe0:	e8 b1 43 00 00       	call   80105396 <safestrcpy>

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
80101020:	e8 4f 6e 00 00       	call   80107e74 <switchuvm>
  freevm(oldpgdir);
80101025:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101028:	89 04 24             	mov    %eax,(%esp)
8010102b:	e8 10 73 00 00       	call   80108340 <freevm>
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
80101043:	e8 f8 72 00 00       	call   80108340 <freevm>
  if(ip){
80101048:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010104c:	74 10                	je     8010105e <exec+0x436>
    iunlockput(ip);
8010104e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101051:	89 04 24             	mov    %eax,(%esp)
80101054:	e8 c0 0c 00 00       	call   80101d19 <iunlockput>
    end_op();
80101059:	e8 37 26 00 00       	call   80103695 <end_op>
  }
  return -1;
8010105e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101063:	c9                   	leave  
80101064:	c3                   	ret    
80101065:	00 00                	add    %al,(%eax)
	...

80101068 <strcpy1>:
#include "file.h"
#include "container.h"



char* strcpy1(char *s, char *t){
80101068:	55                   	push   %ebp
80101069:	89 e5                	mov    %esp,%ebp
8010106b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80101074:	90                   	nop
80101075:	8b 45 08             	mov    0x8(%ebp),%eax
80101078:	8d 50 01             	lea    0x1(%eax),%edx
8010107b:	89 55 08             	mov    %edx,0x8(%ebp)
8010107e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101081:	8d 4a 01             	lea    0x1(%edx),%ecx
80101084:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80101087:	8a 12                	mov    (%edx),%dl
80101089:	88 10                	mov    %dl,(%eax)
8010108b:	8a 00                	mov    (%eax),%al
8010108d:	84 c0                	test   %al,%al
8010108f:	75 e4                	jne    80101075 <strcpy1+0xd>
    ;
  return os;
80101091:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80101094:	c9                   	leave  
80101095:	c3                   	ret    

80101096 <strcmp2>:

int
strcmp2(const char *p, const char *q){
80101096:	55                   	push   %ebp
80101097:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80101099:	eb 06                	jmp    801010a1 <strcmp2+0xb>
    p++, q++;
8010109b:	ff 45 08             	incl   0x8(%ebp)
8010109e:	ff 45 0c             	incl   0xc(%ebp)
  return os;
}

int
strcmp2(const char *p, const char *q){
  while(*p && *p == *q)
801010a1:	8b 45 08             	mov    0x8(%ebp),%eax
801010a4:	8a 00                	mov    (%eax),%al
801010a6:	84 c0                	test   %al,%al
801010a8:	74 0e                	je     801010b8 <strcmp2+0x22>
801010aa:	8b 45 08             	mov    0x8(%ebp),%eax
801010ad:	8a 10                	mov    (%eax),%dl
801010af:	8b 45 0c             	mov    0xc(%ebp),%eax
801010b2:	8a 00                	mov    (%eax),%al
801010b4:	38 c2                	cmp    %al,%dl
801010b6:	74 e3                	je     8010109b <strcmp2+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801010b8:	8b 45 08             	mov    0x8(%ebp),%eax
801010bb:	8a 00                	mov    (%eax),%al
801010bd:	0f b6 d0             	movzbl %al,%edx
801010c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801010c3:	8a 00                	mov    (%eax),%al
801010c5:	0f b6 c0             	movzbl %al,%eax
801010c8:	29 c2                	sub    %eax,%edx
801010ca:	89 d0                	mov    %edx,%eax
}
801010cc:	5d                   	pop    %ebp
801010cd:	c3                   	ret    

801010ce <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010ce:	55                   	push   %ebp
801010cf:	89 e5                	mov    %esp,%ebp
801010d1:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801010d4:	c7 44 24 04 83 8b 10 	movl   $0x80108b83,0x4(%esp)
801010db:	80 
801010dc:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
801010e3:	e8 1e 3e 00 00       	call   80104f06 <initlock>
}
801010e8:	c9                   	leave  
801010e9:	c3                   	ret    

801010ea <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010ea:	55                   	push   %ebp
801010eb:	89 e5                	mov    %esp,%ebp
801010ed:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
801010f0:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
801010f7:	e8 2b 3e 00 00       	call   80104f27 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010fc:	c7 45 f4 14 23 11 80 	movl   $0x80112314,-0xc(%ebp)
80101103:	eb 29                	jmp    8010112e <filealloc+0x44>
    if(f->ref == 0){
80101105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101108:	8b 40 04             	mov    0x4(%eax),%eax
8010110b:	85 c0                	test   %eax,%eax
8010110d:	75 1b                	jne    8010112a <filealloc+0x40>
      f->ref = 1;
8010110f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101112:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101119:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
80101120:	e8 6c 3e 00 00       	call   80104f91 <release>
      return f;
80101125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101128:	eb 1e                	jmp    80101148 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010112a:	83 45 f4 1c          	addl   $0x1c,-0xc(%ebp)
8010112e:	81 7d f4 04 2e 11 80 	cmpl   $0x80112e04,-0xc(%ebp)
80101135:	72 ce                	jb     80101105 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101137:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
8010113e:	e8 4e 3e 00 00       	call   80104f91 <release>
  return 0;
80101143:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101148:	c9                   	leave  
80101149:	c3                   	ret    

8010114a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010114a:	55                   	push   %ebp
8010114b:	89 e5                	mov    %esp,%ebp
8010114d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101150:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
80101157:	e8 cb 3d 00 00       	call   80104f27 <acquire>
  if(f->ref < 1)
8010115c:	8b 45 08             	mov    0x8(%ebp),%eax
8010115f:	8b 40 04             	mov    0x4(%eax),%eax
80101162:	85 c0                	test   %eax,%eax
80101164:	7f 0c                	jg     80101172 <filedup+0x28>
    panic("filedup");
80101166:	c7 04 24 8a 8b 10 80 	movl   $0x80108b8a,(%esp)
8010116d:	e8 e2 f3 ff ff       	call   80100554 <panic>
  f->ref++;
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	8b 40 04             	mov    0x4(%eax),%eax
80101178:	8d 50 01             	lea    0x1(%eax),%edx
8010117b:	8b 45 08             	mov    0x8(%ebp),%eax
8010117e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101181:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
80101188:	e8 04 3e 00 00       	call   80104f91 <release>
  return f;
8010118d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101190:	c9                   	leave  
80101191:	c3                   	ret    

80101192 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101192:	55                   	push   %ebp
80101193:	89 e5                	mov    %esp,%ebp
80101195:	57                   	push   %edi
80101196:	56                   	push   %esi
80101197:	53                   	push   %ebx
80101198:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
8010119b:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
801011a2:	e8 80 3d 00 00       	call   80104f27 <acquire>
  if(f->ref < 1)
801011a7:	8b 45 08             	mov    0x8(%ebp),%eax
801011aa:	8b 40 04             	mov    0x4(%eax),%eax
801011ad:	85 c0                	test   %eax,%eax
801011af:	7f 0c                	jg     801011bd <fileclose+0x2b>
    panic("fileclose");
801011b1:	c7 04 24 92 8b 10 80 	movl   $0x80108b92,(%esp)
801011b8:	e8 97 f3 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
801011bd:	8b 45 08             	mov    0x8(%ebp),%eax
801011c0:	8b 40 04             	mov    0x4(%eax),%eax
801011c3:	8d 50 ff             	lea    -0x1(%eax),%edx
801011c6:	8b 45 08             	mov    0x8(%ebp),%eax
801011c9:	89 50 04             	mov    %edx,0x4(%eax)
801011cc:	8b 45 08             	mov    0x8(%ebp),%eax
801011cf:	8b 40 04             	mov    0x4(%eax),%eax
801011d2:	85 c0                	test   %eax,%eax
801011d4:	7e 0e                	jle    801011e4 <fileclose+0x52>
    release(&ftable.lock);
801011d6:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
801011dd:	e8 af 3d 00 00       	call   80104f91 <release>
801011e2:	eb 70                	jmp    80101254 <fileclose+0xc2>
    return;
  }
  ff = *f;
801011e4:	8b 45 08             	mov    0x8(%ebp),%eax
801011e7:	8d 55 cc             	lea    -0x34(%ebp),%edx
801011ea:	89 c3                	mov    %eax,%ebx
801011ec:	b8 07 00 00 00       	mov    $0x7,%eax
801011f1:	89 d7                	mov    %edx,%edi
801011f3:	89 de                	mov    %ebx,%esi
801011f5:	89 c1                	mov    %eax,%ecx
801011f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
801011f9:	8b 45 08             	mov    0x8(%ebp),%eax
801011fc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101203:	8b 45 08             	mov    0x8(%ebp),%eax
80101206:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010120c:	c7 04 24 e0 22 11 80 	movl   $0x801122e0,(%esp)
80101213:	e8 79 3d 00 00       	call   80104f91 <release>

  if(ff.type == FD_PIPE)
80101218:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010121b:	83 f8 01             	cmp    $0x1,%eax
8010121e:	75 17                	jne    80101237 <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101220:	8a 45 d5             	mov    -0x2b(%ebp),%al
80101223:	0f be d0             	movsbl %al,%edx
80101226:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101229:	89 54 24 04          	mov    %edx,0x4(%esp)
8010122d:	89 04 24             	mov    %eax,(%esp)
80101230:	e8 6e 2d 00 00       	call   80103fa3 <pipeclose>
80101235:	eb 1d                	jmp    80101254 <fileclose+0xc2>
  else if(ff.type == FD_INODE){
80101237:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010123a:	83 f8 02             	cmp    $0x2,%eax
8010123d:	75 15                	jne    80101254 <fileclose+0xc2>
    begin_op();
8010123f:	e8 cf 23 00 00       	call   80103613 <begin_op>
    iput(ff.ip);
80101244:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101247:	89 04 24             	mov    %eax,(%esp)
8010124a:	e8 19 0a 00 00       	call   80101c68 <iput>
    end_op();
8010124f:	e8 41 24 00 00       	call   80103695 <end_op>
  }
}
80101254:	83 c4 3c             	add    $0x3c,%esp
80101257:	5b                   	pop    %ebx
80101258:	5e                   	pop    %esi
80101259:	5f                   	pop    %edi
8010125a:	5d                   	pop    %ebp
8010125b:	c3                   	ret    

8010125c <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010125c:	55                   	push   %ebp
8010125d:	89 e5                	mov    %esp,%ebp
8010125f:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101262:	8b 45 08             	mov    0x8(%ebp),%eax
80101265:	8b 00                	mov    (%eax),%eax
80101267:	83 f8 02             	cmp    $0x2,%eax
8010126a:	75 38                	jne    801012a4 <filestat+0x48>
    ilock(f->ip);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	89 04 24             	mov    %eax,(%esp)
80101275:	e8 a0 08 00 00       	call   80101b1a <ilock>
    stati(f->ip, st);
8010127a:	8b 45 08             	mov    0x8(%ebp),%eax
8010127d:	8b 40 10             	mov    0x10(%eax),%eax
80101280:	8b 55 0c             	mov    0xc(%ebp),%edx
80101283:	89 54 24 04          	mov    %edx,0x4(%esp)
80101287:	89 04 24             	mov    %eax,(%esp)
8010128a:	e8 de 0c 00 00       	call   80101f6d <stati>
    iunlock(f->ip);
8010128f:	8b 45 08             	mov    0x8(%ebp),%eax
80101292:	8b 40 10             	mov    0x10(%eax),%eax
80101295:	89 04 24             	mov    %eax,(%esp)
80101298:	e8 87 09 00 00       	call   80101c24 <iunlock>
    return 0;
8010129d:	b8 00 00 00 00       	mov    $0x0,%eax
801012a2:	eb 05                	jmp    801012a9 <filestat+0x4d>
  }
  return -1;
801012a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012a9:	c9                   	leave  
801012aa:	c3                   	ret    

801012ab <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012ab:	55                   	push   %ebp
801012ac:	89 e5                	mov    %esp,%ebp
801012ae:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801012b1:	8b 45 08             	mov    0x8(%ebp),%eax
801012b4:	8a 40 08             	mov    0x8(%eax),%al
801012b7:	84 c0                	test   %al,%al
801012b9:	75 0a                	jne    801012c5 <fileread+0x1a>
    return -1;
801012bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012c0:	e9 9f 00 00 00       	jmp    80101364 <fileread+0xb9>
  if(f->type == FD_PIPE)
801012c5:	8b 45 08             	mov    0x8(%ebp),%eax
801012c8:	8b 00                	mov    (%eax),%eax
801012ca:	83 f8 01             	cmp    $0x1,%eax
801012cd:	75 1e                	jne    801012ed <fileread+0x42>
    return piperead(f->pipe, addr, n);
801012cf:	8b 45 08             	mov    0x8(%ebp),%eax
801012d2:	8b 40 0c             	mov    0xc(%eax),%eax
801012d5:	8b 55 10             	mov    0x10(%ebp),%edx
801012d8:	89 54 24 08          	mov    %edx,0x8(%esp)
801012dc:	8b 55 0c             	mov    0xc(%ebp),%edx
801012df:	89 54 24 04          	mov    %edx,0x4(%esp)
801012e3:	89 04 24             	mov    %eax,(%esp)
801012e6:	e8 36 2e 00 00       	call   80104121 <piperead>
801012eb:	eb 77                	jmp    80101364 <fileread+0xb9>
  if(f->type == FD_INODE){
801012ed:	8b 45 08             	mov    0x8(%ebp),%eax
801012f0:	8b 00                	mov    (%eax),%eax
801012f2:	83 f8 02             	cmp    $0x2,%eax
801012f5:	75 61                	jne    80101358 <fileread+0xad>
    ilock(f->ip);
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	8b 40 10             	mov    0x10(%eax),%eax
801012fd:	89 04 24             	mov    %eax,(%esp)
80101300:	e8 15 08 00 00       	call   80101b1a <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101305:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101308:	8b 45 08             	mov    0x8(%ebp),%eax
8010130b:	8b 50 14             	mov    0x14(%eax),%edx
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 40 10             	mov    0x10(%eax),%eax
80101314:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101318:	89 54 24 08          	mov    %edx,0x8(%esp)
8010131c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010131f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101323:	89 04 24             	mov    %eax,(%esp)
80101326:	e8 86 0c 00 00       	call   80101fb1 <readi>
8010132b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010132e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101332:	7e 11                	jle    80101345 <fileread+0x9a>
      f->off += r;
80101334:	8b 45 08             	mov    0x8(%ebp),%eax
80101337:	8b 50 14             	mov    0x14(%eax),%edx
8010133a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010133d:	01 c2                	add    %eax,%edx
8010133f:	8b 45 08             	mov    0x8(%ebp),%eax
80101342:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101345:	8b 45 08             	mov    0x8(%ebp),%eax
80101348:	8b 40 10             	mov    0x10(%eax),%eax
8010134b:	89 04 24             	mov    %eax,(%esp)
8010134e:	e8 d1 08 00 00       	call   80101c24 <iunlock>
    return r;
80101353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101356:	eb 0c                	jmp    80101364 <fileread+0xb9>
  }
  panic("fileread");
80101358:	c7 04 24 9c 8b 10 80 	movl   $0x80108b9c,(%esp)
8010135f:	e8 f0 f1 ff ff       	call   80100554 <panic>
}
80101364:	c9                   	leave  
80101365:	c3                   	ret    

80101366 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101366:	55                   	push   %ebp
80101367:	89 e5                	mov    %esp,%ebp
80101369:	53                   	push   %ebx
8010136a:	83 ec 54             	sub    $0x54,%esp
  int r;
  int i;
  char x[32];
  x[0] = '\0';
8010136d:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)

  for(i = 0; i < 32; i++){
80101371:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101378:	eb 38                	jmp    801013b2 <filewrite+0x4c>
    x[i] = f->path[i];
8010137a:	8b 45 08             	mov    0x8(%ebp),%eax
8010137d:	8b 50 18             	mov    0x18(%eax),%edx
80101380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101383:	01 d0                	add    %edx,%eax
80101385:	8a 00                	mov    (%eax),%al
80101387:	8d 4d c0             	lea    -0x40(%ebp),%ecx
8010138a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010138d:	01 ca                	add    %ecx,%edx
8010138f:	88 02                	mov    %al,(%edx)
    if(f->path[i] == '/'){
80101391:	8b 45 08             	mov    0x8(%ebp),%eax
80101394:	8b 50 18             	mov    0x18(%eax),%edx
80101397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139a:	01 d0                	add    %edx,%eax
8010139c:	8a 00                	mov    (%eax),%al
8010139e:	3c 2f                	cmp    $0x2f,%al
801013a0:	75 0d                	jne    801013af <filewrite+0x49>
      x[i] = '\0';
801013a2:	8d 55 c0             	lea    -0x40(%ebp),%edx
801013a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a8:	01 d0                	add    %edx,%eax
801013aa:	c6 00 00             	movb   $0x0,(%eax)
      break;
801013ad:	eb 09                	jmp    801013b8 <filewrite+0x52>
  int r;
  int i;
  char x[32];
  x[0] = '\0';

  for(i = 0; i < 32; i++){
801013af:	ff 45 f4             	incl   -0xc(%ebp)
801013b2:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%ebp)
801013b6:	7e c2                	jle    8010137a <filewrite+0x14>
      x[i] = '\0';
      break;
    }
  }

  if(f->writable == 0)
801013b8:	8b 45 08             	mov    0x8(%ebp),%eax
801013bb:	8a 40 09             	mov    0x9(%eax),%al
801013be:	84 c0                	test   %al,%al
801013c0:	75 0a                	jne    801013cc <filewrite+0x66>
    return -1;
801013c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c7:	e9 46 01 00 00       	jmp    80101512 <filewrite+0x1ac>
  if(f->type == FD_PIPE)
801013cc:	8b 45 08             	mov    0x8(%ebp),%eax
801013cf:	8b 00                	mov    (%eax),%eax
801013d1:	83 f8 01             	cmp    $0x1,%eax
801013d4:	75 21                	jne    801013f7 <filewrite+0x91>
    return pipewrite(f->pipe, addr, n);
801013d6:	8b 45 08             	mov    0x8(%ebp),%eax
801013d9:	8b 40 0c             	mov    0xc(%eax),%eax
801013dc:	8b 55 10             	mov    0x10(%ebp),%edx
801013df:	89 54 24 08          	mov    %edx,0x8(%esp)
801013e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801013e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801013ea:	89 04 24             	mov    %eax,(%esp)
801013ed:	e8 43 2c 00 00       	call   80104035 <pipewrite>
801013f2:	e9 1b 01 00 00       	jmp    80101512 <filewrite+0x1ac>
  if(f->type == FD_INODE){
801013f7:	8b 45 08             	mov    0x8(%ebp),%eax
801013fa:	8b 00                	mov    (%eax),%eax
801013fc:	83 f8 02             	cmp    $0x2,%eax
801013ff:	0f 85 01 01 00 00    	jne    80101506 <filewrite+0x1a0>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101405:	c7 45 e8 00 1a 00 00 	movl   $0x1a00,-0x18(%ebp)
    int i = 0;
8010140c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    while(i < n){
80101413:	e9 ce 00 00 00       	jmp    801014e6 <filewrite+0x180>
      int n1 = n - i;
80101418:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010141b:	8b 55 10             	mov    0x10(%ebp),%edx
8010141e:	29 c2                	sub    %eax,%edx
80101420:	89 d0                	mov    %edx,%eax
80101422:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(n1 > max)
80101425:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101428:	3b 45 e8             	cmp    -0x18(%ebp),%eax
8010142b:	7e 06                	jle    80101433 <filewrite+0xcd>
        n1 = max;
8010142d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101430:	89 45 ec             	mov    %eax,-0x14(%ebp)

      begin_op();
80101433:	e8 db 21 00 00       	call   80103613 <begin_op>
      ilock(f->ip);
80101438:	8b 45 08             	mov    0x8(%ebp),%eax
8010143b:	8b 40 10             	mov    0x10(%eax),%eax
8010143e:	89 04 24             	mov    %eax,(%esp)
80101441:	e8 d4 06 00 00       	call   80101b1a <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0){
80101446:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101449:	8b 45 08             	mov    0x8(%ebp),%eax
8010144c:	8b 50 14             	mov    0x14(%eax),%edx
8010144f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101452:	8b 45 0c             	mov    0xc(%ebp),%eax
80101455:	01 c3                	add    %eax,%ebx
80101457:	8b 45 08             	mov    0x8(%ebp),%eax
8010145a:	8b 40 10             	mov    0x10(%eax),%eax
8010145d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101461:	89 54 24 08          	mov    %edx,0x8(%esp)
80101465:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101469:	89 04 24             	mov    %eax,(%esp)
8010146c:	e8 a4 0c 00 00       	call   80102115 <writei>
80101471:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101474:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80101478:	7e 37                	jle    801014b1 <filewrite+0x14b>
        f->off += r;
8010147a:	8b 45 08             	mov    0x8(%ebp),%eax
8010147d:	8b 50 14             	mov    0x14(%eax),%edx
80101480:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101483:	01 c2                	add    %eax,%edx
80101485:	8b 45 08             	mov    0x8(%ebp),%eax
80101488:	89 50 14             	mov    %edx,0x14(%eax)
        int c_num = find(x);
8010148b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010148e:	89 04 24             	mov    %eax,(%esp)
80101491:	e8 a0 72 00 00       	call   80108736 <find>
80101496:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(c_num >= 0){
80101499:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010149d:	78 12                	js     801014b1 <filewrite+0x14b>
          set_curr_disk(r, c_num);
8010149f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801014a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801014a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014a9:	89 04 24             	mov    %eax,(%esp)
801014ac:	e8 ee 74 00 00       	call   8010899f <set_curr_disk>
        }
      }
      iunlock(f->ip);
801014b1:	8b 45 08             	mov    0x8(%ebp),%eax
801014b4:	8b 40 10             	mov    0x10(%eax),%eax
801014b7:	89 04 24             	mov    %eax,(%esp)
801014ba:	e8 65 07 00 00       	call   80101c24 <iunlock>
      end_op();
801014bf:	e8 d1 21 00 00       	call   80103695 <end_op>

      if(r < 0)
801014c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801014c8:	79 02                	jns    801014cc <filewrite+0x166>
        break;
801014ca:	eb 26                	jmp    801014f2 <filewrite+0x18c>
      if(r != n1)
801014cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801014d2:	74 0c                	je     801014e0 <filewrite+0x17a>
        panic("short filewrite");
801014d4:	c7 04 24 a5 8b 10 80 	movl   $0x80108ba5,(%esp)
801014db:	e8 74 f0 ff ff       	call   80100554 <panic>
      i += r;
801014e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014e3:	01 45 f0             	add    %eax,-0x10(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801014e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e9:	3b 45 10             	cmp    0x10(%ebp),%eax
801014ec:	0f 8c 26 ff ff ff    	jl     80101418 <filewrite+0xb2>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801014f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f5:	3b 45 10             	cmp    0x10(%ebp),%eax
801014f8:	75 05                	jne    801014ff <filewrite+0x199>
801014fa:	8b 45 10             	mov    0x10(%ebp),%eax
801014fd:	eb 05                	jmp    80101504 <filewrite+0x19e>
801014ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101504:	eb 0c                	jmp    80101512 <filewrite+0x1ac>
  }
  panic("filewrite");
80101506:	c7 04 24 b5 8b 10 80 	movl   $0x80108bb5,(%esp)
8010150d:	e8 42 f0 ff ff       	call   80100554 <panic>
}
80101512:	83 c4 54             	add    $0x54,%esp
80101515:	5b                   	pop    %ebx
80101516:	5d                   	pop    %ebp
80101517:	c3                   	ret    

80101518 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101518:	55                   	push   %ebp
80101519:	89 e5                	mov    %esp,%ebp
8010151b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010151e:	8b 45 08             	mov    0x8(%ebp),%eax
80101521:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101528:	00 
80101529:	89 04 24             	mov    %eax,(%esp)
8010152c:	e8 84 ec ff ff       	call   801001b5 <bread>
80101531:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101537:	83 c0 5c             	add    $0x5c,%eax
8010153a:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101541:	00 
80101542:	89 44 24 04          	mov    %eax,0x4(%esp)
80101546:	8b 45 0c             	mov    0xc(%ebp),%eax
80101549:	89 04 24             	mov    %eax,(%esp)
8010154c:	e8 02 3d 00 00       	call   80105253 <memmove>
  brelse(bp);
80101551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101554:	89 04 24             	mov    %eax,(%esp)
80101557:	e8 d0 ec ff ff       	call   8010022c <brelse>
}
8010155c:	c9                   	leave  
8010155d:	c3                   	ret    

8010155e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010155e:	55                   	push   %ebp
8010155f:	89 e5                	mov    %esp,%ebp
80101561:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101564:	8b 55 0c             	mov    0xc(%ebp),%edx
80101567:	8b 45 08             	mov    0x8(%ebp),%eax
8010156a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010156e:	89 04 24             	mov    %eax,(%esp)
80101571:	e8 3f ec ff ff       	call   801001b5 <bread>
80101576:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010157c:	83 c0 5c             	add    $0x5c,%eax
8010157f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101586:	00 
80101587:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010158e:	00 
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 f3 3b 00 00       	call   8010518a <memset>
  log_write(bp);
80101597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159a:	89 04 24             	mov    %eax,(%esp)
8010159d:	e8 75 22 00 00       	call   80103817 <log_write>
  brelse(bp);
801015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a5:	89 04 24             	mov    %eax,(%esp)
801015a8:	e8 7f ec ff ff       	call   8010022c <brelse>
}
801015ad:	c9                   	leave  
801015ae:	c3                   	ret    

801015af <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801015af:	55                   	push   %ebp
801015b0:	89 e5                	mov    %esp,%ebp
801015b2:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801015b5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801015bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801015c3:	e9 03 01 00 00       	jmp    801016cb <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
801015c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015cb:	85 c0                	test   %eax,%eax
801015cd:	79 05                	jns    801015d4 <balloc+0x25>
801015cf:	05 ff 0f 00 00       	add    $0xfff,%eax
801015d4:	c1 f8 0c             	sar    $0xc,%eax
801015d7:	89 c2                	mov    %eax,%edx
801015d9:	a1 98 2e 11 80       	mov    0x80112e98,%eax
801015de:	01 d0                	add    %edx,%eax
801015e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801015e4:	8b 45 08             	mov    0x8(%ebp),%eax
801015e7:	89 04 24             	mov    %eax,(%esp)
801015ea:	e8 c6 eb ff ff       	call   801001b5 <bread>
801015ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015f9:	e9 9b 00 00 00       	jmp    80101699 <balloc+0xea>
      m = 1 << (bi % 8);
801015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101601:	25 07 00 00 80       	and    $0x80000007,%eax
80101606:	85 c0                	test   %eax,%eax
80101608:	79 05                	jns    8010160f <balloc+0x60>
8010160a:	48                   	dec    %eax
8010160b:	83 c8 f8             	or     $0xfffffff8,%eax
8010160e:	40                   	inc    %eax
8010160f:	ba 01 00 00 00       	mov    $0x1,%edx
80101614:	88 c1                	mov    %al,%cl
80101616:	d3 e2                	shl    %cl,%edx
80101618:	89 d0                	mov    %edx,%eax
8010161a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101620:	85 c0                	test   %eax,%eax
80101622:	79 03                	jns    80101627 <balloc+0x78>
80101624:	83 c0 07             	add    $0x7,%eax
80101627:	c1 f8 03             	sar    $0x3,%eax
8010162a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010162d:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101631:	0f b6 c0             	movzbl %al,%eax
80101634:	23 45 e8             	and    -0x18(%ebp),%eax
80101637:	85 c0                	test   %eax,%eax
80101639:	75 5b                	jne    80101696 <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010163b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163e:	85 c0                	test   %eax,%eax
80101640:	79 03                	jns    80101645 <balloc+0x96>
80101642:	83 c0 07             	add    $0x7,%eax
80101645:	c1 f8 03             	sar    $0x3,%eax
80101648:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010164b:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
8010164f:	88 d1                	mov    %dl,%cl
80101651:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101654:	09 ca                	or     %ecx,%edx
80101656:	88 d1                	mov    %dl,%cl
80101658:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010165b:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010165f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101662:	89 04 24             	mov    %eax,(%esp)
80101665:	e8 ad 21 00 00       	call   80103817 <log_write>
        brelse(bp);
8010166a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010166d:	89 04 24             	mov    %eax,(%esp)
80101670:	e8 b7 eb ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
80101675:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101678:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010167b:	01 c2                	add    %eax,%edx
8010167d:	8b 45 08             	mov    0x8(%ebp),%eax
80101680:	89 54 24 04          	mov    %edx,0x4(%esp)
80101684:	89 04 24             	mov    %eax,(%esp)
80101687:	e8 d2 fe ff ff       	call   8010155e <bzero>
        return b + bi;
8010168c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101692:	01 d0                	add    %edx,%eax
80101694:	eb 51                	jmp    801016e7 <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101696:	ff 45 f0             	incl   -0x10(%ebp)
80101699:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801016a0:	7f 17                	jg     801016b9 <balloc+0x10a>
801016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016a8:	01 d0                	add    %edx,%eax
801016aa:	89 c2                	mov    %eax,%edx
801016ac:	a1 80 2e 11 80       	mov    0x80112e80,%eax
801016b1:	39 c2                	cmp    %eax,%edx
801016b3:	0f 82 45 ff ff ff    	jb     801015fe <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801016b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016bc:	89 04 24             	mov    %eax,(%esp)
801016bf:	e8 68 eb ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801016c4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ce:	a1 80 2e 11 80       	mov    0x80112e80,%eax
801016d3:	39 c2                	cmp    %eax,%edx
801016d5:	0f 82 ed fe ff ff    	jb     801015c8 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801016db:	c7 04 24 c0 8b 10 80 	movl   $0x80108bc0,(%esp)
801016e2:	e8 6d ee ff ff       	call   80100554 <panic>
}
801016e7:	c9                   	leave  
801016e8:	c3                   	ret    

801016e9 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016e9:	55                   	push   %ebp
801016ea:	89 e5                	mov    %esp,%ebp
801016ec:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801016ef:	c7 44 24 04 80 2e 11 	movl   $0x80112e80,0x4(%esp)
801016f6:	80 
801016f7:	8b 45 08             	mov    0x8(%ebp),%eax
801016fa:	89 04 24             	mov    %eax,(%esp)
801016fd:	e8 16 fe ff ff       	call   80101518 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101702:	8b 45 0c             	mov    0xc(%ebp),%eax
80101705:	c1 e8 0c             	shr    $0xc,%eax
80101708:	89 c2                	mov    %eax,%edx
8010170a:	a1 98 2e 11 80       	mov    0x80112e98,%eax
8010170f:	01 c2                	add    %eax,%edx
80101711:	8b 45 08             	mov    0x8(%ebp),%eax
80101714:	89 54 24 04          	mov    %edx,0x4(%esp)
80101718:	89 04 24             	mov    %eax,(%esp)
8010171b:	e8 95 ea ff ff       	call   801001b5 <bread>
80101720:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101723:	8b 45 0c             	mov    0xc(%ebp),%eax
80101726:	25 ff 0f 00 00       	and    $0xfff,%eax
8010172b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010172e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101731:	25 07 00 00 80       	and    $0x80000007,%eax
80101736:	85 c0                	test   %eax,%eax
80101738:	79 05                	jns    8010173f <bfree+0x56>
8010173a:	48                   	dec    %eax
8010173b:	83 c8 f8             	or     $0xfffffff8,%eax
8010173e:	40                   	inc    %eax
8010173f:	ba 01 00 00 00       	mov    $0x1,%edx
80101744:	88 c1                	mov    %al,%cl
80101746:	d3 e2                	shl    %cl,%edx
80101748:	89 d0                	mov    %edx,%eax
8010174a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010174d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101750:	85 c0                	test   %eax,%eax
80101752:	79 03                	jns    80101757 <bfree+0x6e>
80101754:	83 c0 07             	add    $0x7,%eax
80101757:	c1 f8 03             	sar    $0x3,%eax
8010175a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010175d:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101761:	0f b6 c0             	movzbl %al,%eax
80101764:	23 45 ec             	and    -0x14(%ebp),%eax
80101767:	85 c0                	test   %eax,%eax
80101769:	75 0c                	jne    80101777 <bfree+0x8e>
    panic("freeing free block");
8010176b:	c7 04 24 d6 8b 10 80 	movl   $0x80108bd6,(%esp)
80101772:	e8 dd ed ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
80101777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177a:	85 c0                	test   %eax,%eax
8010177c:	79 03                	jns    80101781 <bfree+0x98>
8010177e:	83 c0 07             	add    $0x7,%eax
80101781:	c1 f8 03             	sar    $0x3,%eax
80101784:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101787:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
8010178b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010178e:	f7 d1                	not    %ecx
80101790:	21 ca                	and    %ecx,%edx
80101792:	88 d1                	mov    %dl,%cl
80101794:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101797:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179e:	89 04 24             	mov    %eax,(%esp)
801017a1:	e8 71 20 00 00       	call   80103817 <log_write>
  brelse(bp);
801017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a9:	89 04 24             	mov    %eax,(%esp)
801017ac:	e8 7b ea ff ff       	call   8010022c <brelse>
}
801017b1:	c9                   	leave  
801017b2:	c3                   	ret    

801017b3 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801017b3:	55                   	push   %ebp
801017b4:	89 e5                	mov    %esp,%ebp
801017b6:	57                   	push   %edi
801017b7:	56                   	push   %esi
801017b8:	53                   	push   %ebx
801017b9:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
801017bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801017c3:	c7 44 24 04 e9 8b 10 	movl   $0x80108be9,0x4(%esp)
801017ca:	80 
801017cb:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
801017d2:	e8 2f 37 00 00       	call   80104f06 <initlock>
  for(i = 0; i < NINODE; i++) {
801017d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017de:	eb 2b                	jmp    8010180b <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
801017e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017e3:	89 d0                	mov    %edx,%eax
801017e5:	c1 e0 03             	shl    $0x3,%eax
801017e8:	01 d0                	add    %edx,%eax
801017ea:	c1 e0 04             	shl    $0x4,%eax
801017ed:	83 c0 30             	add    $0x30,%eax
801017f0:	05 a0 2e 11 80       	add    $0x80112ea0,%eax
801017f5:	83 c0 10             	add    $0x10,%eax
801017f8:	c7 44 24 04 f0 8b 10 	movl   $0x80108bf0,0x4(%esp)
801017ff:	80 
80101800:	89 04 24             	mov    %eax,(%esp)
80101803:	e8 c0 35 00 00       	call   80104dc8 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101808:	ff 45 e4             	incl   -0x1c(%ebp)
8010180b:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010180f:	7e cf                	jle    801017e0 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
80101811:	c7 44 24 04 80 2e 11 	movl   $0x80112e80,0x4(%esp)
80101818:	80 
80101819:	8b 45 08             	mov    0x8(%ebp),%eax
8010181c:	89 04 24             	mov    %eax,(%esp)
8010181f:	e8 f4 fc ff ff       	call   80101518 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101824:	a1 98 2e 11 80       	mov    0x80112e98,%eax
80101829:	8b 3d 94 2e 11 80    	mov    0x80112e94,%edi
8010182f:	8b 35 90 2e 11 80    	mov    0x80112e90,%esi
80101835:	8b 1d 8c 2e 11 80    	mov    0x80112e8c,%ebx
8010183b:	8b 0d 88 2e 11 80    	mov    0x80112e88,%ecx
80101841:	8b 15 84 2e 11 80    	mov    0x80112e84,%edx
80101847:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010184a:	8b 15 80 2e 11 80    	mov    0x80112e80,%edx
80101850:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101854:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101858:	89 74 24 14          	mov    %esi,0x14(%esp)
8010185c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101860:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101864:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101867:	89 44 24 08          	mov    %eax,0x8(%esp)
8010186b:	89 d0                	mov    %edx,%eax
8010186d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101871:	c7 04 24 f8 8b 10 80 	movl   $0x80108bf8,(%esp)
80101878:	e8 44 eb ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010187d:	83 c4 4c             	add    $0x4c,%esp
80101880:	5b                   	pop    %ebx
80101881:	5e                   	pop    %esi
80101882:	5f                   	pop    %edi
80101883:	5d                   	pop    %ebp
80101884:	c3                   	ret    

80101885 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101885:	55                   	push   %ebp
80101886:	89 e5                	mov    %esp,%ebp
80101888:	83 ec 28             	sub    $0x28,%esp
8010188b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010188e:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101892:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101899:	e9 9b 00 00 00       	jmp    80101939 <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
8010189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a1:	c1 e8 03             	shr    $0x3,%eax
801018a4:	89 c2                	mov    %eax,%edx
801018a6:	a1 94 2e 11 80       	mov    0x80112e94,%eax
801018ab:	01 d0                	add    %edx,%eax
801018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801018b1:	8b 45 08             	mov    0x8(%ebp),%eax
801018b4:	89 04 24             	mov    %eax,(%esp)
801018b7:	e8 f9 e8 ff ff       	call   801001b5 <bread>
801018bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c2:	8d 50 5c             	lea    0x5c(%eax),%edx
801018c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c8:	83 e0 07             	and    $0x7,%eax
801018cb:	c1 e0 06             	shl    $0x6,%eax
801018ce:	01 d0                	add    %edx,%eax
801018d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018d6:	8b 00                	mov    (%eax),%eax
801018d8:	66 85 c0             	test   %ax,%ax
801018db:	75 4e                	jne    8010192b <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
801018dd:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801018e4:	00 
801018e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801018ec:	00 
801018ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018f0:	89 04 24             	mov    %eax,(%esp)
801018f3:	e8 92 38 00 00       	call   8010518a <memset>
      dip->type = type;
801018f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801018fe:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
80101901:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101904:	89 04 24             	mov    %eax,(%esp)
80101907:	e8 0b 1f 00 00       	call   80103817 <log_write>
      brelse(bp);
8010190c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190f:	89 04 24             	mov    %eax,(%esp)
80101912:	e8 15 e9 ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
80101917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	89 04 24             	mov    %eax,(%esp)
80101924:	e8 ea 00 00 00       	call   80101a13 <iget>
80101929:	eb 2a                	jmp    80101955 <ialloc+0xd0>
    }
    brelse(bp);
8010192b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192e:	89 04 24             	mov    %eax,(%esp)
80101931:	e8 f6 e8 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101936:	ff 45 f4             	incl   -0xc(%ebp)
80101939:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010193c:	a1 88 2e 11 80       	mov    0x80112e88,%eax
80101941:	39 c2                	cmp    %eax,%edx
80101943:	0f 82 55 ff ff ff    	jb     8010189e <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101949:	c7 04 24 4b 8c 10 80 	movl   $0x80108c4b,(%esp)
80101950:	e8 ff eb ff ff       	call   80100554 <panic>
}
80101955:	c9                   	leave  
80101956:	c3                   	ret    

80101957 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101957:	55                   	push   %ebp
80101958:	89 e5                	mov    %esp,%ebp
8010195a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010195d:	8b 45 08             	mov    0x8(%ebp),%eax
80101960:	8b 40 04             	mov    0x4(%eax),%eax
80101963:	c1 e8 03             	shr    $0x3,%eax
80101966:	89 c2                	mov    %eax,%edx
80101968:	a1 94 2e 11 80       	mov    0x80112e94,%eax
8010196d:	01 c2                	add    %eax,%edx
8010196f:	8b 45 08             	mov    0x8(%ebp),%eax
80101972:	8b 00                	mov    (%eax),%eax
80101974:	89 54 24 04          	mov    %edx,0x4(%esp)
80101978:	89 04 24             	mov    %eax,(%esp)
8010197b:	e8 35 e8 ff ff       	call   801001b5 <bread>
80101980:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101986:	8d 50 5c             	lea    0x5c(%eax),%edx
80101989:	8b 45 08             	mov    0x8(%ebp),%eax
8010198c:	8b 40 04             	mov    0x4(%eax),%eax
8010198f:	83 e0 07             	and    $0x7,%eax
80101992:	c1 e0 06             	shl    $0x6,%eax
80101995:	01 d0                	add    %edx,%eax
80101997:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010199a:	8b 45 08             	mov    0x8(%ebp),%eax
8010199d:	8b 40 50             	mov    0x50(%eax),%eax
801019a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019a3:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801019a6:	8b 45 08             	mov    0x8(%ebp),%eax
801019a9:	66 8b 40 52          	mov    0x52(%eax),%ax
801019ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019b0:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801019b4:	8b 45 08             	mov    0x8(%ebp),%eax
801019b7:	8b 40 54             	mov    0x54(%eax),%eax
801019ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019bd:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801019c1:	8b 45 08             	mov    0x8(%ebp),%eax
801019c4:	66 8b 40 56          	mov    0x56(%eax),%ax
801019c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019cb:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	8b 50 58             	mov    0x58(%eax),%edx
801019d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d8:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019db:	8b 45 08             	mov    0x8(%ebp),%eax
801019de:	8d 50 5c             	lea    0x5c(%eax),%edx
801019e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e4:	83 c0 0c             	add    $0xc,%eax
801019e7:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019ee:	00 
801019ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801019f3:	89 04 24             	mov    %eax,(%esp)
801019f6:	e8 58 38 00 00       	call   80105253 <memmove>
  log_write(bp);
801019fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fe:	89 04 24             	mov    %eax,(%esp)
80101a01:	e8 11 1e 00 00       	call   80103817 <log_write>
  brelse(bp);
80101a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a09:	89 04 24             	mov    %eax,(%esp)
80101a0c:	e8 1b e8 ff ff       	call   8010022c <brelse>
}
80101a11:	c9                   	leave  
80101a12:	c3                   	ret    

80101a13 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a13:	55                   	push   %ebp
80101a14:	89 e5                	mov    %esp,%ebp
80101a16:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a19:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
80101a20:	e8 02 35 00 00       	call   80104f27 <acquire>

  // Is the inode already cached?
  empty = 0;
80101a25:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a2c:	c7 45 f4 d4 2e 11 80 	movl   $0x80112ed4,-0xc(%ebp)
80101a33:	eb 5c                	jmp    80101a91 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a38:	8b 40 08             	mov    0x8(%eax),%eax
80101a3b:	85 c0                	test   %eax,%eax
80101a3d:	7e 35                	jle    80101a74 <iget+0x61>
80101a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a42:	8b 00                	mov    (%eax),%eax
80101a44:	3b 45 08             	cmp    0x8(%ebp),%eax
80101a47:	75 2b                	jne    80101a74 <iget+0x61>
80101a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4c:	8b 40 04             	mov    0x4(%eax),%eax
80101a4f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a52:	75 20                	jne    80101a74 <iget+0x61>
      ip->ref++;
80101a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a57:	8b 40 08             	mov    0x8(%eax),%eax
80101a5a:	8d 50 01             	lea    0x1(%eax),%edx
80101a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a60:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a63:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
80101a6a:	e8 22 35 00 00       	call   80104f91 <release>
      return ip;
80101a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a72:	eb 72                	jmp    80101ae6 <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a74:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a78:	75 10                	jne    80101a8a <iget+0x77>
80101a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7d:	8b 40 08             	mov    0x8(%eax),%eax
80101a80:	85 c0                	test   %eax,%eax
80101a82:	75 06                	jne    80101a8a <iget+0x77>
      empty = ip;
80101a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a87:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a8a:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a91:	81 7d f4 f4 4a 11 80 	cmpl   $0x80114af4,-0xc(%ebp)
80101a98:	72 9b                	jb     80101a35 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a9e:	75 0c                	jne    80101aac <iget+0x99>
    panic("iget: no inodes");
80101aa0:	c7 04 24 5d 8c 10 80 	movl   $0x80108c5d,(%esp)
80101aa7:	e8 a8 ea ff ff       	call   80100554 <panic>

  ip = empty;
80101aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab5:	8b 55 08             	mov    0x8(%ebp),%edx
80101ab8:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ac0:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad0:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101ad7:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
80101ade:	e8 ae 34 00 00       	call   80104f91 <release>

  return ip;
80101ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ae6:	c9                   	leave  
80101ae7:	c3                   	ret    

80101ae8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101ae8:	55                   	push   %ebp
80101ae9:	89 e5                	mov    %esp,%ebp
80101aeb:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101aee:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
80101af5:	e8 2d 34 00 00       	call   80104f27 <acquire>
  ip->ref++;
80101afa:	8b 45 08             	mov    0x8(%ebp),%eax
80101afd:	8b 40 08             	mov    0x8(%eax),%eax
80101b00:	8d 50 01             	lea    0x1(%eax),%edx
80101b03:	8b 45 08             	mov    0x8(%ebp),%eax
80101b06:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b09:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
80101b10:	e8 7c 34 00 00       	call   80104f91 <release>
  return ip;
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b18:	c9                   	leave  
80101b19:	c3                   	ret    

80101b1a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b1a:	55                   	push   %ebp
80101b1b:	89 e5                	mov    %esp,%ebp
80101b1d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b24:	74 0a                	je     80101b30 <ilock+0x16>
80101b26:	8b 45 08             	mov    0x8(%ebp),%eax
80101b29:	8b 40 08             	mov    0x8(%eax),%eax
80101b2c:	85 c0                	test   %eax,%eax
80101b2e:	7f 0c                	jg     80101b3c <ilock+0x22>
    panic("ilock");
80101b30:	c7 04 24 6d 8c 10 80 	movl   $0x80108c6d,(%esp)
80101b37:	e8 18 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3f:	83 c0 0c             	add    $0xc,%eax
80101b42:	89 04 24             	mov    %eax,(%esp)
80101b45:	e8 b8 32 00 00       	call   80104e02 <acquiresleep>

  if(ip->valid == 0){
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b50:	85 c0                	test   %eax,%eax
80101b52:	0f 85 ca 00 00 00    	jne    80101c22 <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b58:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5b:	8b 40 04             	mov    0x4(%eax),%eax
80101b5e:	c1 e8 03             	shr    $0x3,%eax
80101b61:	89 c2                	mov    %eax,%edx
80101b63:	a1 94 2e 11 80       	mov    0x80112e94,%eax
80101b68:	01 c2                	add    %eax,%edx
80101b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6d:	8b 00                	mov    (%eax),%eax
80101b6f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b73:	89 04 24             	mov    %eax,(%esp)
80101b76:	e8 3a e6 ff ff       	call   801001b5 <bread>
80101b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b81:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	8b 40 04             	mov    0x4(%eax),%eax
80101b8a:	83 e0 07             	and    $0x7,%eax
80101b8d:	c1 e0 06             	shl    $0x6,%eax
80101b90:	01 d0                	add    %edx,%eax
80101b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b98:	8b 00                	mov    (%eax),%eax
80101b9a:	8b 55 08             	mov    0x8(%ebp),%edx
80101b9d:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba4:	66 8b 40 02          	mov    0x2(%eax),%ax
80101ba8:	8b 55 08             	mov    0x8(%ebp),%edx
80101bab:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb2:	8b 40 04             	mov    0x4(%eax),%eax
80101bb5:	8b 55 08             	mov    0x8(%ebp),%edx
80101bb8:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bbf:	66 8b 40 06          	mov    0x6(%eax),%ax
80101bc3:	8b 55 08             	mov    0x8(%ebp),%edx
80101bc6:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bcd:	8b 50 08             	mov    0x8(%eax),%edx
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd9:	8d 50 0c             	lea    0xc(%eax),%edx
80101bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdf:	83 c0 5c             	add    $0x5c,%eax
80101be2:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101be9:	00 
80101bea:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bee:	89 04 24             	mov    %eax,(%esp)
80101bf1:	e8 5d 36 00 00       	call   80105253 <memmove>
    brelse(bp);
80101bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf9:	89 04 24             	mov    %eax,(%esp)
80101bfc:	e8 2b e6 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0e:	8b 40 50             	mov    0x50(%eax),%eax
80101c11:	66 85 c0             	test   %ax,%ax
80101c14:	75 0c                	jne    80101c22 <ilock+0x108>
      panic("ilock: no type");
80101c16:	c7 04 24 73 8c 10 80 	movl   $0x80108c73,(%esp)
80101c1d:	e8 32 e9 ff ff       	call   80100554 <panic>
  }
}
80101c22:	c9                   	leave  
80101c23:	c3                   	ret    

80101c24 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c24:	55                   	push   %ebp
80101c25:	89 e5                	mov    %esp,%ebp
80101c27:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c2a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c2e:	74 1c                	je     80101c4c <iunlock+0x28>
80101c30:	8b 45 08             	mov    0x8(%ebp),%eax
80101c33:	83 c0 0c             	add    $0xc,%eax
80101c36:	89 04 24             	mov    %eax,(%esp)
80101c39:	e8 61 32 00 00       	call   80104e9f <holdingsleep>
80101c3e:	85 c0                	test   %eax,%eax
80101c40:	74 0a                	je     80101c4c <iunlock+0x28>
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	8b 40 08             	mov    0x8(%eax),%eax
80101c48:	85 c0                	test   %eax,%eax
80101c4a:	7f 0c                	jg     80101c58 <iunlock+0x34>
    panic("iunlock");
80101c4c:	c7 04 24 82 8c 10 80 	movl   $0x80108c82,(%esp)
80101c53:	e8 fc e8 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c58:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5b:	83 c0 0c             	add    $0xc,%eax
80101c5e:	89 04 24             	mov    %eax,(%esp)
80101c61:	e8 f7 31 00 00       	call   80104e5d <releasesleep>
}
80101c66:	c9                   	leave  
80101c67:	c3                   	ret    

80101c68 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c68:	55                   	push   %ebp
80101c69:	89 e5                	mov    %esp,%ebp
80101c6b:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c71:	83 c0 0c             	add    $0xc,%eax
80101c74:	89 04 24             	mov    %eax,(%esp)
80101c77:	e8 86 31 00 00       	call   80104e02 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7f:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c82:	85 c0                	test   %eax,%eax
80101c84:	74 5c                	je     80101ce2 <iput+0x7a>
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	66 8b 40 56          	mov    0x56(%eax),%ax
80101c8d:	66 85 c0             	test   %ax,%ax
80101c90:	75 50                	jne    80101ce2 <iput+0x7a>
    acquire(&icache.lock);
80101c92:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
80101c99:	e8 89 32 00 00       	call   80104f27 <acquire>
    int r = ip->ref;
80101c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca1:	8b 40 08             	mov    0x8(%eax),%eax
80101ca4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101ca7:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
80101cae:	e8 de 32 00 00       	call   80104f91 <release>
    if(r == 1){
80101cb3:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cb7:	75 29                	jne    80101ce2 <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	89 04 24             	mov    %eax,(%esp)
80101cbf:	e8 86 01 00 00       	call   80101e4a <itrunc>
      ip->type = 0;
80101cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc7:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd0:	89 04 24             	mov    %eax,(%esp)
80101cd3:	e8 7f fc ff ff       	call   80101957 <iupdate>
      ip->valid = 0;
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce5:	83 c0 0c             	add    $0xc,%eax
80101ce8:	89 04 24             	mov    %eax,(%esp)
80101ceb:	e8 6d 31 00 00       	call   80104e5d <releasesleep>

  acquire(&icache.lock);
80101cf0:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
80101cf7:	e8 2b 32 00 00       	call   80104f27 <acquire>
  ip->ref--;
80101cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cff:	8b 40 08             	mov    0x8(%eax),%eax
80101d02:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d05:	8b 45 08             	mov    0x8(%ebp),%eax
80101d08:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d0b:	c7 04 24 a0 2e 11 80 	movl   $0x80112ea0,(%esp)
80101d12:	e8 7a 32 00 00       	call   80104f91 <release>
}
80101d17:	c9                   	leave  
80101d18:	c3                   	ret    

80101d19 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d19:	55                   	push   %ebp
80101d1a:	89 e5                	mov    %esp,%ebp
80101d1c:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d22:	89 04 24             	mov    %eax,(%esp)
80101d25:	e8 fa fe ff ff       	call   80101c24 <iunlock>
  iput(ip);
80101d2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2d:	89 04 24             	mov    %eax,(%esp)
80101d30:	e8 33 ff ff ff       	call   80101c68 <iput>
}
80101d35:	c9                   	leave  
80101d36:	c3                   	ret    

80101d37 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d37:	55                   	push   %ebp
80101d38:	89 e5                	mov    %esp,%ebp
80101d3a:	53                   	push   %ebx
80101d3b:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d3e:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d42:	77 3e                	ja     80101d82 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101d44:	8b 45 08             	mov    0x8(%ebp),%eax
80101d47:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d4a:	83 c2 14             	add    $0x14,%edx
80101d4d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d58:	75 20                	jne    80101d7a <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	8b 00                	mov    (%eax),%eax
80101d5f:	89 04 24             	mov    %eax,(%esp)
80101d62:	e8 48 f8 ff ff       	call   801015af <balloc>
80101d67:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d70:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d76:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d7d:	e9 c2 00 00 00       	jmp    80101e44 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101d82:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d86:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d8a:	0f 87 a8 00 00 00    	ja     80101e38 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d90:	8b 45 08             	mov    0x8(%ebp),%eax
80101d93:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101da0:	75 1c                	jne    80101dbe <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	8b 00                	mov    (%eax),%eax
80101da7:	89 04 24             	mov    %eax,(%esp)
80101daa:	e8 00 f8 ff ff       	call   801015af <balloc>
80101daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db2:	8b 45 08             	mov    0x8(%ebp),%eax
80101db5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	8b 00                	mov    (%eax),%eax
80101dc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dc6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dca:	89 04 24             	mov    %eax,(%esp)
80101dcd:	e8 e3 e3 ff ff       	call   801001b5 <bread>
80101dd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dd8:	83 c0 5c             	add    $0x5c,%eax
80101ddb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101dde:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101de8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101deb:	01 d0                	add    %edx,%eax
80101ded:	8b 00                	mov    (%eax),%eax
80101def:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101df2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101df6:	75 30                	jne    80101e28 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101df8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e05:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101e08:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0b:	8b 00                	mov    (%eax),%eax
80101e0d:	89 04 24             	mov    %eax,(%esp)
80101e10:	e8 9a f7 ff ff       	call   801015af <balloc>
80101e15:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e1b:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e20:	89 04 24             	mov    %eax,(%esp)
80101e23:	e8 ef 19 00 00       	call   80103817 <log_write>
    }
    brelse(bp);
80101e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2b:	89 04 24             	mov    %eax,(%esp)
80101e2e:	e8 f9 e3 ff ff       	call   8010022c <brelse>
    return addr;
80101e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e36:	eb 0c                	jmp    80101e44 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101e38:	c7 04 24 8a 8c 10 80 	movl   $0x80108c8a,(%esp)
80101e3f:	e8 10 e7 ff ff       	call   80100554 <panic>
}
80101e44:	83 c4 24             	add    $0x24,%esp
80101e47:	5b                   	pop    %ebx
80101e48:	5d                   	pop    %ebp
80101e49:	c3                   	ret    

80101e4a <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e4a:	55                   	push   %ebp
80101e4b:	89 e5                	mov    %esp,%ebp
80101e4d:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e57:	eb 43                	jmp    80101e9c <itrunc+0x52>
    if(ip->addrs[i]){
80101e59:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e5f:	83 c2 14             	add    $0x14,%edx
80101e62:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e66:	85 c0                	test   %eax,%eax
80101e68:	74 2f                	je     80101e99 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e70:	83 c2 14             	add    $0x14,%edx
80101e73:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	8b 00                	mov    (%eax),%eax
80101e7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e80:	89 04 24             	mov    %eax,(%esp)
80101e83:	e8 61 f8 ff ff       	call   801016e9 <bfree>
      ip->addrs[i] = 0;
80101e88:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e8e:	83 c2 14             	add    $0x14,%edx
80101e91:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e98:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e99:	ff 45 f4             	incl   -0xc(%ebp)
80101e9c:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ea0:	7e b7                	jle    80101e59 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101eab:	85 c0                	test   %eax,%eax
80101ead:	0f 84 a3 00 00 00    	je     80101f56 <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebf:	8b 00                	mov    (%eax),%eax
80101ec1:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ec5:	89 04 24             	mov    %eax,(%esp)
80101ec8:	e8 e8 e2 ff ff       	call   801001b5 <bread>
80101ecd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ed0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ed3:	83 c0 5c             	add    $0x5c,%eax
80101ed6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ed9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ee0:	eb 3a                	jmp    80101f1c <itrunc+0xd2>
      if(a[j])
80101ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eef:	01 d0                	add    %edx,%eax
80101ef1:	8b 00                	mov    (%eax),%eax
80101ef3:	85 c0                	test   %eax,%eax
80101ef5:	74 22                	je     80101f19 <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101efa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f04:	01 d0                	add    %edx,%eax
80101f06:	8b 10                	mov    (%eax),%edx
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	8b 00                	mov    (%eax),%eax
80101f0d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f11:	89 04 24             	mov    %eax,(%esp)
80101f14:	e8 d0 f7 ff ff       	call   801016e9 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101f19:	ff 45 f0             	incl   -0x10(%ebp)
80101f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f1f:	83 f8 7f             	cmp    $0x7f,%eax
80101f22:	76 be                	jbe    80101ee2 <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101f24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f27:	89 04 24             	mov    %eax,(%esp)
80101f2a:	e8 fd e2 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f32:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f38:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3b:	8b 00                	mov    (%eax),%eax
80101f3d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f41:	89 04 24             	mov    %eax,(%esp)
80101f44:	e8 a0 f7 ff ff       	call   801016e9 <bfree>
    ip->addrs[NDIRECT] = 0;
80101f49:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4c:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f53:	00 00 00 
  }

  ip->size = 0;
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	89 04 24             	mov    %eax,(%esp)
80101f66:	e8 ec f9 ff ff       	call   80101957 <iupdate>
}
80101f6b:	c9                   	leave  
80101f6c:	c3                   	ret    

80101f6d <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f6d:	55                   	push   %ebp
80101f6e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
80101f73:	8b 00                	mov    (%eax),%eax
80101f75:	89 c2                	mov    %eax,%edx
80101f77:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f7a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	8b 50 04             	mov    0x4(%eax),%edx
80101f83:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f86:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f89:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8c:	8b 40 50             	mov    0x50(%eax),%eax
80101f8f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f92:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	66 8b 40 56          	mov    0x56(%eax),%ax
80101f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f9f:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa6:	8b 50 58             	mov    0x58(%eax),%edx
80101fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fac:	89 50 10             	mov    %edx,0x10(%eax)
}
80101faf:	5d                   	pop    %ebp
80101fb0:	c3                   	ret    

80101fb1 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fb1:	55                   	push   %ebp
80101fb2:	89 e5                	mov    %esp,%ebp
80101fb4:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fba:	8b 40 50             	mov    0x50(%eax),%eax
80101fbd:	66 83 f8 03          	cmp    $0x3,%ax
80101fc1:	75 60                	jne    80102023 <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc6:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fca:	66 85 c0             	test   %ax,%ax
80101fcd:	78 20                	js     80101fef <readi+0x3e>
80101fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd2:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fd6:	66 83 f8 09          	cmp    $0x9,%ax
80101fda:	7f 13                	jg     80101fef <readi+0x3e>
80101fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdf:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fe3:	98                   	cwtl   
80101fe4:	8b 04 c5 20 2e 11 80 	mov    -0x7feed1e0(,%eax,8),%eax
80101feb:	85 c0                	test   %eax,%eax
80101fed:	75 0a                	jne    80101ff9 <readi+0x48>
      return -1;
80101fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff4:	e9 1a 01 00 00       	jmp    80102113 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffc:	66 8b 40 52          	mov    0x52(%eax),%ax
80102000:	98                   	cwtl   
80102001:	8b 04 c5 20 2e 11 80 	mov    -0x7feed1e0(,%eax,8),%eax
80102008:	8b 55 14             	mov    0x14(%ebp),%edx
8010200b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010200f:	8b 55 0c             	mov    0xc(%ebp),%edx
80102012:	89 54 24 04          	mov    %edx,0x4(%esp)
80102016:	8b 55 08             	mov    0x8(%ebp),%edx
80102019:	89 14 24             	mov    %edx,(%esp)
8010201c:	ff d0                	call   *%eax
8010201e:	e9 f0 00 00 00       	jmp    80102113 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80102023:	8b 45 08             	mov    0x8(%ebp),%eax
80102026:	8b 40 58             	mov    0x58(%eax),%eax
80102029:	3b 45 10             	cmp    0x10(%ebp),%eax
8010202c:	72 0d                	jb     8010203b <readi+0x8a>
8010202e:	8b 45 14             	mov    0x14(%ebp),%eax
80102031:	8b 55 10             	mov    0x10(%ebp),%edx
80102034:	01 d0                	add    %edx,%eax
80102036:	3b 45 10             	cmp    0x10(%ebp),%eax
80102039:	73 0a                	jae    80102045 <readi+0x94>
    return -1;
8010203b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102040:	e9 ce 00 00 00       	jmp    80102113 <readi+0x162>
  if(off + n > ip->size)
80102045:	8b 45 14             	mov    0x14(%ebp),%eax
80102048:	8b 55 10             	mov    0x10(%ebp),%edx
8010204b:	01 c2                	add    %eax,%edx
8010204d:	8b 45 08             	mov    0x8(%ebp),%eax
80102050:	8b 40 58             	mov    0x58(%eax),%eax
80102053:	39 c2                	cmp    %eax,%edx
80102055:	76 0c                	jbe    80102063 <readi+0xb2>
    n = ip->size - off;
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	8b 40 58             	mov    0x58(%eax),%eax
8010205d:	2b 45 10             	sub    0x10(%ebp),%eax
80102060:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102063:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010206a:	e9 95 00 00 00       	jmp    80102104 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010206f:	8b 45 10             	mov    0x10(%ebp),%eax
80102072:	c1 e8 09             	shr    $0x9,%eax
80102075:	89 44 24 04          	mov    %eax,0x4(%esp)
80102079:	8b 45 08             	mov    0x8(%ebp),%eax
8010207c:	89 04 24             	mov    %eax,(%esp)
8010207f:	e8 b3 fc ff ff       	call   80101d37 <bmap>
80102084:	8b 55 08             	mov    0x8(%ebp),%edx
80102087:	8b 12                	mov    (%edx),%edx
80102089:	89 44 24 04          	mov    %eax,0x4(%esp)
8010208d:	89 14 24             	mov    %edx,(%esp)
80102090:	e8 20 e1 ff ff       	call   801001b5 <bread>
80102095:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102098:	8b 45 10             	mov    0x10(%ebp),%eax
8010209b:	25 ff 01 00 00       	and    $0x1ff,%eax
801020a0:	89 c2                	mov    %eax,%edx
801020a2:	b8 00 02 00 00       	mov    $0x200,%eax
801020a7:	29 d0                	sub    %edx,%eax
801020a9:	89 c1                	mov    %eax,%ecx
801020ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ae:	8b 55 14             	mov    0x14(%ebp),%edx
801020b1:	29 c2                	sub    %eax,%edx
801020b3:	89 c8                	mov    %ecx,%eax
801020b5:	39 d0                	cmp    %edx,%eax
801020b7:	76 02                	jbe    801020bb <readi+0x10a>
801020b9:	89 d0                	mov    %edx,%eax
801020bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020be:	8b 45 10             	mov    0x10(%ebp),%eax
801020c1:	25 ff 01 00 00       	and    $0x1ff,%eax
801020c6:	8d 50 50             	lea    0x50(%eax),%edx
801020c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020cc:	01 d0                	add    %edx,%eax
801020ce:	8d 50 0c             	lea    0xc(%eax),%edx
801020d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020d4:	89 44 24 08          	mov    %eax,0x8(%esp)
801020d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801020dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801020df:	89 04 24             	mov    %eax,(%esp)
801020e2:	e8 6c 31 00 00       	call   80105253 <memmove>
    brelse(bp);
801020e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020ea:	89 04 24             	mov    %eax,(%esp)
801020ed:	e8 3a e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020f5:	01 45 f4             	add    %eax,-0xc(%ebp)
801020f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020fb:	01 45 10             	add    %eax,0x10(%ebp)
801020fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102101:	01 45 0c             	add    %eax,0xc(%ebp)
80102104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102107:	3b 45 14             	cmp    0x14(%ebp),%eax
8010210a:	0f 82 5f ff ff ff    	jb     8010206f <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102110:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102113:	c9                   	leave  
80102114:	c3                   	ret    

80102115 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102115:	55                   	push   %ebp
80102116:	89 e5                	mov    %esp,%ebp
80102118:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010211b:	8b 45 08             	mov    0x8(%ebp),%eax
8010211e:	8b 40 50             	mov    0x50(%eax),%eax
80102121:	66 83 f8 03          	cmp    $0x3,%ax
80102125:	75 60                	jne    80102187 <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102127:	8b 45 08             	mov    0x8(%ebp),%eax
8010212a:	66 8b 40 52          	mov    0x52(%eax),%ax
8010212e:	66 85 c0             	test   %ax,%ax
80102131:	78 20                	js     80102153 <writei+0x3e>
80102133:	8b 45 08             	mov    0x8(%ebp),%eax
80102136:	66 8b 40 52          	mov    0x52(%eax),%ax
8010213a:	66 83 f8 09          	cmp    $0x9,%ax
8010213e:	7f 13                	jg     80102153 <writei+0x3e>
80102140:	8b 45 08             	mov    0x8(%ebp),%eax
80102143:	66 8b 40 52          	mov    0x52(%eax),%ax
80102147:	98                   	cwtl   
80102148:	8b 04 c5 24 2e 11 80 	mov    -0x7feed1dc(,%eax,8),%eax
8010214f:	85 c0                	test   %eax,%eax
80102151:	75 0a                	jne    8010215d <writei+0x48>
      return -1;
80102153:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102158:	e9 45 01 00 00       	jmp    801022a2 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
8010215d:	8b 45 08             	mov    0x8(%ebp),%eax
80102160:	66 8b 40 52          	mov    0x52(%eax),%ax
80102164:	98                   	cwtl   
80102165:	8b 04 c5 24 2e 11 80 	mov    -0x7feed1dc(,%eax,8),%eax
8010216c:	8b 55 14             	mov    0x14(%ebp),%edx
8010216f:	89 54 24 08          	mov    %edx,0x8(%esp)
80102173:	8b 55 0c             	mov    0xc(%ebp),%edx
80102176:	89 54 24 04          	mov    %edx,0x4(%esp)
8010217a:	8b 55 08             	mov    0x8(%ebp),%edx
8010217d:	89 14 24             	mov    %edx,(%esp)
80102180:	ff d0                	call   *%eax
80102182:	e9 1b 01 00 00       	jmp    801022a2 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80102187:	8b 45 08             	mov    0x8(%ebp),%eax
8010218a:	8b 40 58             	mov    0x58(%eax),%eax
8010218d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102190:	72 0d                	jb     8010219f <writei+0x8a>
80102192:	8b 45 14             	mov    0x14(%ebp),%eax
80102195:	8b 55 10             	mov    0x10(%ebp),%edx
80102198:	01 d0                	add    %edx,%eax
8010219a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010219d:	73 0a                	jae    801021a9 <writei+0x94>
    return -1;
8010219f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021a4:	e9 f9 00 00 00       	jmp    801022a2 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
801021a9:	8b 45 14             	mov    0x14(%ebp),%eax
801021ac:	8b 55 10             	mov    0x10(%ebp),%edx
801021af:	01 d0                	add    %edx,%eax
801021b1:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021b6:	76 0a                	jbe    801021c2 <writei+0xad>
    return -1;
801021b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021bd:	e9 e0 00 00 00       	jmp    801022a2 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021c9:	e9 a0 00 00 00       	jmp    8010226e <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021ce:	8b 45 10             	mov    0x10(%ebp),%eax
801021d1:	c1 e8 09             	shr    $0x9,%eax
801021d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	89 04 24             	mov    %eax,(%esp)
801021de:	e8 54 fb ff ff       	call   80101d37 <bmap>
801021e3:	8b 55 08             	mov    0x8(%ebp),%edx
801021e6:	8b 12                	mov    (%edx),%edx
801021e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ec:	89 14 24             	mov    %edx,(%esp)
801021ef:	e8 c1 df ff ff       	call   801001b5 <bread>
801021f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021f7:	8b 45 10             	mov    0x10(%ebp),%eax
801021fa:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ff:	89 c2                	mov    %eax,%edx
80102201:	b8 00 02 00 00       	mov    $0x200,%eax
80102206:	29 d0                	sub    %edx,%eax
80102208:	89 c1                	mov    %eax,%ecx
8010220a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220d:	8b 55 14             	mov    0x14(%ebp),%edx
80102210:	29 c2                	sub    %eax,%edx
80102212:	89 c8                	mov    %ecx,%eax
80102214:	39 d0                	cmp    %edx,%eax
80102216:	76 02                	jbe    8010221a <writei+0x105>
80102218:	89 d0                	mov    %edx,%eax
8010221a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010221d:	8b 45 10             	mov    0x10(%ebp),%eax
80102220:	25 ff 01 00 00       	and    $0x1ff,%eax
80102225:	8d 50 50             	lea    0x50(%eax),%edx
80102228:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010222b:	01 d0                	add    %edx,%eax
8010222d:	8d 50 0c             	lea    0xc(%eax),%edx
80102230:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102233:	89 44 24 08          	mov    %eax,0x8(%esp)
80102237:	8b 45 0c             	mov    0xc(%ebp),%eax
8010223a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010223e:	89 14 24             	mov    %edx,(%esp)
80102241:	e8 0d 30 00 00       	call   80105253 <memmove>
    log_write(bp);
80102246:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102249:	89 04 24             	mov    %eax,(%esp)
8010224c:	e8 c6 15 00 00       	call   80103817 <log_write>
    brelse(bp);
80102251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102254:	89 04 24             	mov    %eax,(%esp)
80102257:	e8 d0 df ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010225c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010225f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102262:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102265:	01 45 10             	add    %eax,0x10(%ebp)
80102268:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010226b:	01 45 0c             	add    %eax,0xc(%ebp)
8010226e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102271:	3b 45 14             	cmp    0x14(%ebp),%eax
80102274:	0f 82 54 ff ff ff    	jb     801021ce <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010227a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010227e:	74 1f                	je     8010229f <writei+0x18a>
80102280:	8b 45 08             	mov    0x8(%ebp),%eax
80102283:	8b 40 58             	mov    0x58(%eax),%eax
80102286:	3b 45 10             	cmp    0x10(%ebp),%eax
80102289:	73 14                	jae    8010229f <writei+0x18a>
    ip->size = off;
8010228b:	8b 45 08             	mov    0x8(%ebp),%eax
8010228e:	8b 55 10             	mov    0x10(%ebp),%edx
80102291:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102294:	8b 45 08             	mov    0x8(%ebp),%eax
80102297:	89 04 24             	mov    %eax,(%esp)
8010229a:	e8 b8 f6 ff ff       	call   80101957 <iupdate>
  }
  return n;
8010229f:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022a2:	c9                   	leave  
801022a3:	c3                   	ret    

801022a4 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022a4:	55                   	push   %ebp
801022a5:	89 e5                	mov    %esp,%ebp
801022a7:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801022aa:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022b1:	00 
801022b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801022b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801022b9:	8b 45 08             	mov    0x8(%ebp),%eax
801022bc:	89 04 24             	mov    %eax,(%esp)
801022bf:	e8 2e 30 00 00       	call   801052f2 <strncmp>
}
801022c4:	c9                   	leave  
801022c5:	c3                   	ret    

801022c6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022c6:	55                   	push   %ebp
801022c7:	89 e5                	mov    %esp,%ebp
801022c9:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022cc:	8b 45 08             	mov    0x8(%ebp),%eax
801022cf:	8b 40 50             	mov    0x50(%eax),%eax
801022d2:	66 83 f8 01          	cmp    $0x1,%ax
801022d6:	74 0c                	je     801022e4 <dirlookup+0x1e>
    panic("dirlookup not DIR");
801022d8:	c7 04 24 9d 8c 10 80 	movl   $0x80108c9d,(%esp)
801022df:	e8 70 e2 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022eb:	e9 86 00 00 00       	jmp    80102376 <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022f0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022f7:	00 
801022f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801022ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102302:	89 44 24 04          	mov    %eax,0x4(%esp)
80102306:	8b 45 08             	mov    0x8(%ebp),%eax
80102309:	89 04 24             	mov    %eax,(%esp)
8010230c:	e8 a0 fc ff ff       	call   80101fb1 <readi>
80102311:	83 f8 10             	cmp    $0x10,%eax
80102314:	74 0c                	je     80102322 <dirlookup+0x5c>
      panic("dirlookup read");
80102316:	c7 04 24 af 8c 10 80 	movl   $0x80108caf,(%esp)
8010231d:	e8 32 e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102322:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102325:	66 85 c0             	test   %ax,%ax
80102328:	75 02                	jne    8010232c <dirlookup+0x66>
      continue;
8010232a:	eb 46                	jmp    80102372 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
8010232c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010232f:	83 c0 02             	add    $0x2,%eax
80102332:	89 44 24 04          	mov    %eax,0x4(%esp)
80102336:	8b 45 0c             	mov    0xc(%ebp),%eax
80102339:	89 04 24             	mov    %eax,(%esp)
8010233c:	e8 63 ff ff ff       	call   801022a4 <namecmp>
80102341:	85 c0                	test   %eax,%eax
80102343:	75 2d                	jne    80102372 <dirlookup+0xac>
      // entry matches path element
      if(poff)
80102345:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102349:	74 08                	je     80102353 <dirlookup+0x8d>
        *poff = off;
8010234b:	8b 45 10             	mov    0x10(%ebp),%eax
8010234e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102351:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102353:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102356:	0f b7 c0             	movzwl %ax,%eax
80102359:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010235c:	8b 45 08             	mov    0x8(%ebp),%eax
8010235f:	8b 00                	mov    (%eax),%eax
80102361:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102364:	89 54 24 04          	mov    %edx,0x4(%esp)
80102368:	89 04 24             	mov    %eax,(%esp)
8010236b:	e8 a3 f6 ff ff       	call   80101a13 <iget>
80102370:	eb 18                	jmp    8010238a <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102372:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102376:	8b 45 08             	mov    0x8(%ebp),%eax
80102379:	8b 40 58             	mov    0x58(%eax),%eax
8010237c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010237f:	0f 87 6b ff ff ff    	ja     801022f0 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102385:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010238a:	c9                   	leave  
8010238b:	c3                   	ret    

8010238c <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010238c:	55                   	push   %ebp
8010238d:	89 e5                	mov    %esp,%ebp
8010238f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102392:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102399:	00 
8010239a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010239d:	89 44 24 04          	mov    %eax,0x4(%esp)
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	89 04 24             	mov    %eax,(%esp)
801023a7:	e8 1a ff ff ff       	call   801022c6 <dirlookup>
801023ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023b3:	74 15                	je     801023ca <dirlink+0x3e>
    iput(ip);
801023b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023b8:	89 04 24             	mov    %eax,(%esp)
801023bb:	e8 a8 f8 ff ff       	call   80101c68 <iput>
    return -1;
801023c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023c5:	e9 b6 00 00 00       	jmp    80102480 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023d1:	eb 45                	jmp    80102418 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023dd:	00 
801023de:	89 44 24 08          	mov    %eax,0x8(%esp)
801023e2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801023e9:	8b 45 08             	mov    0x8(%ebp),%eax
801023ec:	89 04 24             	mov    %eax,(%esp)
801023ef:	e8 bd fb ff ff       	call   80101fb1 <readi>
801023f4:	83 f8 10             	cmp    $0x10,%eax
801023f7:	74 0c                	je     80102405 <dirlink+0x79>
      panic("dirlink read");
801023f9:	c7 04 24 be 8c 10 80 	movl   $0x80108cbe,(%esp)
80102400:	e8 4f e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102405:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102408:	66 85 c0             	test   %ax,%ax
8010240b:	75 02                	jne    8010240f <dirlink+0x83>
      break;
8010240d:	eb 16                	jmp    80102425 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010240f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102412:	83 c0 10             	add    $0x10,%eax
80102415:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102418:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010241b:	8b 45 08             	mov    0x8(%ebp),%eax
8010241e:	8b 40 58             	mov    0x58(%eax),%eax
80102421:	39 c2                	cmp    %eax,%edx
80102423:	72 ae                	jb     801023d3 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102425:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010242c:	00 
8010242d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102430:	89 44 24 04          	mov    %eax,0x4(%esp)
80102434:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102437:	83 c0 02             	add    $0x2,%eax
8010243a:	89 04 24             	mov    %eax,(%esp)
8010243d:	e8 fe 2e 00 00       	call   80105340 <strncpy>
  de.inum = inum;
80102442:	8b 45 10             	mov    0x10(%ebp),%eax
80102445:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010244c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102453:	00 
80102454:	89 44 24 08          	mov    %eax,0x8(%esp)
80102458:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010245b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010245f:	8b 45 08             	mov    0x8(%ebp),%eax
80102462:	89 04 24             	mov    %eax,(%esp)
80102465:	e8 ab fc ff ff       	call   80102115 <writei>
8010246a:	83 f8 10             	cmp    $0x10,%eax
8010246d:	74 0c                	je     8010247b <dirlink+0xef>
    panic("dirlink");
8010246f:	c7 04 24 cb 8c 10 80 	movl   $0x80108ccb,(%esp)
80102476:	e8 d9 e0 ff ff       	call   80100554 <panic>

  return 0;
8010247b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102480:	c9                   	leave  
80102481:	c3                   	ret    

80102482 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102482:	55                   	push   %ebp
80102483:	89 e5                	mov    %esp,%ebp
80102485:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102488:	eb 03                	jmp    8010248d <skipelem+0xb>
    path++;
8010248a:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010248d:	8b 45 08             	mov    0x8(%ebp),%eax
80102490:	8a 00                	mov    (%eax),%al
80102492:	3c 2f                	cmp    $0x2f,%al
80102494:	74 f4                	je     8010248a <skipelem+0x8>
    path++;
  if(*path == 0)
80102496:	8b 45 08             	mov    0x8(%ebp),%eax
80102499:	8a 00                	mov    (%eax),%al
8010249b:	84 c0                	test   %al,%al
8010249d:	75 0a                	jne    801024a9 <skipelem+0x27>
    return 0;
8010249f:	b8 00 00 00 00       	mov    $0x0,%eax
801024a4:	e9 81 00 00 00       	jmp    8010252a <skipelem+0xa8>
  s = path;
801024a9:	8b 45 08             	mov    0x8(%ebp),%eax
801024ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024af:	eb 03                	jmp    801024b4 <skipelem+0x32>
    path++;
801024b1:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801024b4:	8b 45 08             	mov    0x8(%ebp),%eax
801024b7:	8a 00                	mov    (%eax),%al
801024b9:	3c 2f                	cmp    $0x2f,%al
801024bb:	74 09                	je     801024c6 <skipelem+0x44>
801024bd:	8b 45 08             	mov    0x8(%ebp),%eax
801024c0:	8a 00                	mov    (%eax),%al
801024c2:	84 c0                	test   %al,%al
801024c4:	75 eb                	jne    801024b1 <skipelem+0x2f>
    path++;
  len = path - s;
801024c6:	8b 55 08             	mov    0x8(%ebp),%edx
801024c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024cc:	29 c2                	sub    %eax,%edx
801024ce:	89 d0                	mov    %edx,%eax
801024d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024d3:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024d7:	7e 1c                	jle    801024f5 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
801024d9:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024e0:	00 
801024e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801024e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801024eb:	89 04 24             	mov    %eax,(%esp)
801024ee:	e8 60 2d 00 00       	call   80105253 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024f3:	eb 29                	jmp    8010251e <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801024f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024f8:	89 44 24 08          	mov    %eax,0x8(%esp)
801024fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102503:	8b 45 0c             	mov    0xc(%ebp),%eax
80102506:	89 04 24             	mov    %eax,(%esp)
80102509:	e8 45 2d 00 00       	call   80105253 <memmove>
    name[len] = 0;
8010250e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102511:	8b 45 0c             	mov    0xc(%ebp),%eax
80102514:	01 d0                	add    %edx,%eax
80102516:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102519:	eb 03                	jmp    8010251e <skipelem+0x9c>
    path++;
8010251b:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010251e:	8b 45 08             	mov    0x8(%ebp),%eax
80102521:	8a 00                	mov    (%eax),%al
80102523:	3c 2f                	cmp    $0x2f,%al
80102525:	74 f4                	je     8010251b <skipelem+0x99>
    path++;
  return path;
80102527:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010252a:	c9                   	leave  
8010252b:	c3                   	ret    

8010252c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010252c:	55                   	push   %ebp
8010252d:	89 e5                	mov    %esp,%ebp
8010252f:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102532:	8b 45 08             	mov    0x8(%ebp),%eax
80102535:	8a 00                	mov    (%eax),%al
80102537:	3c 2f                	cmp    $0x2f,%al
80102539:	75 1c                	jne    80102557 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
8010253b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102542:	00 
80102543:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010254a:	e8 c4 f4 ff ff       	call   80101a13 <iget>
8010254f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102552:	e9 ac 00 00 00       	jmp    80102603 <namex+0xd7>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80102557:	e8 af 1d 00 00       	call   8010430b <myproc>
8010255c:	8b 40 68             	mov    0x68(%eax),%eax
8010255f:	89 04 24             	mov    %eax,(%esp)
80102562:	e8 81 f5 ff ff       	call   80101ae8 <idup>
80102567:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010256a:	e9 94 00 00 00       	jmp    80102603 <namex+0xd7>
    ilock(ip);
8010256f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102572:	89 04 24             	mov    %eax,(%esp)
80102575:	e8 a0 f5 ff ff       	call   80101b1a <ilock>
    if(ip->type != T_DIR){
8010257a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010257d:	8b 40 50             	mov    0x50(%eax),%eax
80102580:	66 83 f8 01          	cmp    $0x1,%ax
80102584:	74 15                	je     8010259b <namex+0x6f>
      iunlockput(ip);
80102586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102589:	89 04 24             	mov    %eax,(%esp)
8010258c:	e8 88 f7 ff ff       	call   80101d19 <iunlockput>
      return 0;
80102591:	b8 00 00 00 00       	mov    $0x0,%eax
80102596:	e9 a2 00 00 00       	jmp    8010263d <namex+0x111>
    }
    if(nameiparent && *path == '\0'){
8010259b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010259f:	74 1c                	je     801025bd <namex+0x91>
801025a1:	8b 45 08             	mov    0x8(%ebp),%eax
801025a4:	8a 00                	mov    (%eax),%al
801025a6:	84 c0                	test   %al,%al
801025a8:	75 13                	jne    801025bd <namex+0x91>
      // Stop one level early.
      iunlock(ip);
801025aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ad:	89 04 24             	mov    %eax,(%esp)
801025b0:	e8 6f f6 ff ff       	call   80101c24 <iunlock>
      return ip;
801025b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025b8:	e9 80 00 00 00       	jmp    8010263d <namex+0x111>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801025c4:	00 
801025c5:	8b 45 10             	mov    0x10(%ebp),%eax
801025c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801025cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025cf:	89 04 24             	mov    %eax,(%esp)
801025d2:	e8 ef fc ff ff       	call   801022c6 <dirlookup>
801025d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025de:	75 12                	jne    801025f2 <namex+0xc6>
      iunlockput(ip);
801025e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e3:	89 04 24             	mov    %eax,(%esp)
801025e6:	e8 2e f7 ff ff       	call   80101d19 <iunlockput>
      return 0;
801025eb:	b8 00 00 00 00       	mov    $0x0,%eax
801025f0:	eb 4b                	jmp    8010263d <namex+0x111>
    }
    iunlockput(ip);
801025f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f5:	89 04 24             	mov    %eax,(%esp)
801025f8:	e8 1c f7 ff ff       	call   80101d19 <iunlockput>
    ip = next;
801025fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102600:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80102603:	8b 45 10             	mov    0x10(%ebp),%eax
80102606:	89 44 24 04          	mov    %eax,0x4(%esp)
8010260a:	8b 45 08             	mov    0x8(%ebp),%eax
8010260d:	89 04 24             	mov    %eax,(%esp)
80102610:	e8 6d fe ff ff       	call   80102482 <skipelem>
80102615:	89 45 08             	mov    %eax,0x8(%ebp)
80102618:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010261c:	0f 85 4d ff ff ff    	jne    8010256f <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102622:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102626:	74 12                	je     8010263a <namex+0x10e>
    iput(ip);
80102628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262b:	89 04 24             	mov    %eax,(%esp)
8010262e:	e8 35 f6 ff ff       	call   80101c68 <iput>
    return 0;
80102633:	b8 00 00 00 00       	mov    $0x0,%eax
80102638:	eb 03                	jmp    8010263d <namex+0x111>
  }
  return ip;
8010263a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010263d:	c9                   	leave  
8010263e:	c3                   	ret    

8010263f <namei>:

struct inode*
namei(char *path)
{
8010263f:	55                   	push   %ebp
80102640:	89 e5                	mov    %esp,%ebp
80102642:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102645:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102648:	89 44 24 08          	mov    %eax,0x8(%esp)
8010264c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102653:	00 
80102654:	8b 45 08             	mov    0x8(%ebp),%eax
80102657:	89 04 24             	mov    %eax,(%esp)
8010265a:	e8 cd fe ff ff       	call   8010252c <namex>
}
8010265f:	c9                   	leave  
80102660:	c3                   	ret    

80102661 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102661:	55                   	push   %ebp
80102662:	89 e5                	mov    %esp,%ebp
80102664:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102667:	8b 45 0c             	mov    0xc(%ebp),%eax
8010266a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010266e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102675:	00 
80102676:	8b 45 08             	mov    0x8(%ebp),%eax
80102679:	89 04 24             	mov    %eax,(%esp)
8010267c:	e8 ab fe ff ff       	call   8010252c <namex>
}
80102681:	c9                   	leave  
80102682:	c3                   	ret    
	...

80102684 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102684:	55                   	push   %ebp
80102685:	89 e5                	mov    %esp,%ebp
80102687:	83 ec 14             	sub    $0x14,%esp
8010268a:	8b 45 08             	mov    0x8(%ebp),%eax
8010268d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102691:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102694:	89 c2                	mov    %eax,%edx
80102696:	ec                   	in     (%dx),%al
80102697:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010269a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
8010269d:	c9                   	leave  
8010269e:	c3                   	ret    

8010269f <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010269f:	55                   	push   %ebp
801026a0:	89 e5                	mov    %esp,%ebp
801026a2:	57                   	push   %edi
801026a3:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026a4:	8b 55 08             	mov    0x8(%ebp),%edx
801026a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026aa:	8b 45 10             	mov    0x10(%ebp),%eax
801026ad:	89 cb                	mov    %ecx,%ebx
801026af:	89 df                	mov    %ebx,%edi
801026b1:	89 c1                	mov    %eax,%ecx
801026b3:	fc                   	cld    
801026b4:	f3 6d                	rep insl (%dx),%es:(%edi)
801026b6:	89 c8                	mov    %ecx,%eax
801026b8:	89 fb                	mov    %edi,%ebx
801026ba:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026bd:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801026c0:	5b                   	pop    %ebx
801026c1:	5f                   	pop    %edi
801026c2:	5d                   	pop    %ebp
801026c3:	c3                   	ret    

801026c4 <outb>:

static inline void
outb(ushort port, uchar data)
{
801026c4:	55                   	push   %ebp
801026c5:	89 e5                	mov    %esp,%ebp
801026c7:	83 ec 08             	sub    $0x8,%esp
801026ca:	8b 45 08             	mov    0x8(%ebp),%eax
801026cd:	8b 55 0c             	mov    0xc(%ebp),%edx
801026d0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801026d4:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801026d7:	8a 45 f8             	mov    -0x8(%ebp),%al
801026da:	8b 55 fc             	mov    -0x4(%ebp),%edx
801026dd:	ee                   	out    %al,(%dx)
}
801026de:	c9                   	leave  
801026df:	c3                   	ret    

801026e0 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801026e0:	55                   	push   %ebp
801026e1:	89 e5                	mov    %esp,%ebp
801026e3:	56                   	push   %esi
801026e4:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801026e5:	8b 55 08             	mov    0x8(%ebp),%edx
801026e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026eb:	8b 45 10             	mov    0x10(%ebp),%eax
801026ee:	89 cb                	mov    %ecx,%ebx
801026f0:	89 de                	mov    %ebx,%esi
801026f2:	89 c1                	mov    %eax,%ecx
801026f4:	fc                   	cld    
801026f5:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801026f7:	89 c8                	mov    %ecx,%eax
801026f9:	89 f3                	mov    %esi,%ebx
801026fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026fe:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102701:	5b                   	pop    %ebx
80102702:	5e                   	pop    %esi
80102703:	5d                   	pop    %ebp
80102704:	c3                   	ret    

80102705 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102705:	55                   	push   %ebp
80102706:	89 e5                	mov    %esp,%ebp
80102708:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010270b:	90                   	nop
8010270c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102713:	e8 6c ff ff ff       	call   80102684 <inb>
80102718:	0f b6 c0             	movzbl %al,%eax
8010271b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010271e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102721:	25 c0 00 00 00       	and    $0xc0,%eax
80102726:	83 f8 40             	cmp    $0x40,%eax
80102729:	75 e1                	jne    8010270c <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010272b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010272f:	74 11                	je     80102742 <idewait+0x3d>
80102731:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102734:	83 e0 21             	and    $0x21,%eax
80102737:	85 c0                	test   %eax,%eax
80102739:	74 07                	je     80102742 <idewait+0x3d>
    return -1;
8010273b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102740:	eb 05                	jmp    80102747 <idewait+0x42>
  return 0;
80102742:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102747:	c9                   	leave  
80102748:	c3                   	ret    

80102749 <ideinit>:

void
ideinit(void)
{
80102749:	55                   	push   %ebp
8010274a:	89 e5                	mov    %esp,%ebp
8010274c:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010274f:	c7 44 24 04 d3 8c 10 	movl   $0x80108cd3,0x4(%esp)
80102756:	80 
80102757:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
8010275e:	e8 a3 27 00 00       	call   80104f06 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102763:	a1 c0 51 11 80       	mov    0x801151c0,%eax
80102768:	48                   	dec    %eax
80102769:	89 44 24 04          	mov    %eax,0x4(%esp)
8010276d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102774:	e8 66 04 00 00       	call   80102bdf <ioapicenable>
  idewait(0);
80102779:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102780:	e8 80 ff ff ff       	call   80102705 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102785:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010278c:	00 
8010278d:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102794:	e8 2b ff ff ff       	call   801026c4 <outb>
  for(i=0; i<1000; i++){
80102799:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027a0:	eb 1f                	jmp    801027c1 <ideinit+0x78>
    if(inb(0x1f7) != 0){
801027a2:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027a9:	e8 d6 fe ff ff       	call   80102684 <inb>
801027ae:	84 c0                	test   %al,%al
801027b0:	74 0c                	je     801027be <ideinit+0x75>
      havedisk1 = 1;
801027b2:	c7 05 b8 c8 10 80 01 	movl   $0x1,0x8010c8b8
801027b9:	00 00 00 
      break;
801027bc:	eb 0c                	jmp    801027ca <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801027be:	ff 45 f4             	incl   -0xc(%ebp)
801027c1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801027c8:	7e d8                	jle    801027a2 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801027ca:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801027d1:	00 
801027d2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027d9:	e8 e6 fe ff ff       	call   801026c4 <outb>
}
801027de:	c9                   	leave  
801027df:	c3                   	ret    

801027e0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801027e0:	55                   	push   %ebp
801027e1:	89 e5                	mov    %esp,%ebp
801027e3:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801027e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027ea:	75 0c                	jne    801027f8 <idestart+0x18>
    panic("idestart");
801027ec:	c7 04 24 d7 8c 10 80 	movl   $0x80108cd7,(%esp)
801027f3:	e8 5c dd ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801027f8:	8b 45 08             	mov    0x8(%ebp),%eax
801027fb:	8b 40 08             	mov    0x8(%eax),%eax
801027fe:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102803:	76 0c                	jbe    80102811 <idestart+0x31>
    panic("incorrect blockno");
80102805:	c7 04 24 e0 8c 10 80 	movl   $0x80108ce0,(%esp)
8010280c:	e8 43 dd ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102811:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102818:	8b 45 08             	mov    0x8(%ebp),%eax
8010281b:	8b 50 08             	mov    0x8(%eax),%edx
8010281e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102821:	0f af c2             	imul   %edx,%eax
80102824:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102827:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010282b:	75 07                	jne    80102834 <idestart+0x54>
8010282d:	b8 20 00 00 00       	mov    $0x20,%eax
80102832:	eb 05                	jmp    80102839 <idestart+0x59>
80102834:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102839:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010283c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102840:	75 07                	jne    80102849 <idestart+0x69>
80102842:	b8 30 00 00 00       	mov    $0x30,%eax
80102847:	eb 05                	jmp    8010284e <idestart+0x6e>
80102849:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010284e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102851:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102855:	7e 0c                	jle    80102863 <idestart+0x83>
80102857:	c7 04 24 d7 8c 10 80 	movl   $0x80108cd7,(%esp)
8010285e:	e8 f1 dc ff ff       	call   80100554 <panic>

  idewait(0);
80102863:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010286a:	e8 96 fe ff ff       	call   80102705 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010286f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102876:	00 
80102877:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010287e:	e8 41 fe ff ff       	call   801026c4 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102886:	0f b6 c0             	movzbl %al,%eax
80102889:	89 44 24 04          	mov    %eax,0x4(%esp)
8010288d:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102894:	e8 2b fe ff ff       	call   801026c4 <outb>
  outb(0x1f3, sector & 0xff);
80102899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010289c:	0f b6 c0             	movzbl %al,%eax
8010289f:	89 44 24 04          	mov    %eax,0x4(%esp)
801028a3:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801028aa:	e8 15 fe ff ff       	call   801026c4 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801028af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028b2:	c1 f8 08             	sar    $0x8,%eax
801028b5:	0f b6 c0             	movzbl %al,%eax
801028b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801028bc:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801028c3:	e8 fc fd ff ff       	call   801026c4 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801028c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028cb:	c1 f8 10             	sar    $0x10,%eax
801028ce:	0f b6 c0             	movzbl %al,%eax
801028d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801028d5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801028dc:	e8 e3 fd ff ff       	call   801026c4 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801028e1:	8b 45 08             	mov    0x8(%ebp),%eax
801028e4:	8b 40 04             	mov    0x4(%eax),%eax
801028e7:	83 e0 01             	and    $0x1,%eax
801028ea:	c1 e0 04             	shl    $0x4,%eax
801028ed:	88 c2                	mov    %al,%dl
801028ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028f2:	c1 f8 18             	sar    $0x18,%eax
801028f5:	83 e0 0f             	and    $0xf,%eax
801028f8:	09 d0                	or     %edx,%eax
801028fa:	83 c8 e0             	or     $0xffffffe0,%eax
801028fd:	0f b6 c0             	movzbl %al,%eax
80102900:	89 44 24 04          	mov    %eax,0x4(%esp)
80102904:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010290b:	e8 b4 fd ff ff       	call   801026c4 <outb>
  if(b->flags & B_DIRTY){
80102910:	8b 45 08             	mov    0x8(%ebp),%eax
80102913:	8b 00                	mov    (%eax),%eax
80102915:	83 e0 04             	and    $0x4,%eax
80102918:	85 c0                	test   %eax,%eax
8010291a:	74 36                	je     80102952 <idestart+0x172>
    outb(0x1f7, write_cmd);
8010291c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010291f:	0f b6 c0             	movzbl %al,%eax
80102922:	89 44 24 04          	mov    %eax,0x4(%esp)
80102926:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010292d:	e8 92 fd ff ff       	call   801026c4 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102932:	8b 45 08             	mov    0x8(%ebp),%eax
80102935:	83 c0 5c             	add    $0x5c,%eax
80102938:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010293f:	00 
80102940:	89 44 24 04          	mov    %eax,0x4(%esp)
80102944:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010294b:	e8 90 fd ff ff       	call   801026e0 <outsl>
80102950:	eb 16                	jmp    80102968 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102952:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102955:	0f b6 c0             	movzbl %al,%eax
80102958:	89 44 24 04          	mov    %eax,0x4(%esp)
8010295c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102963:	e8 5c fd ff ff       	call   801026c4 <outb>
  }
}
80102968:	c9                   	leave  
80102969:	c3                   	ret    

8010296a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010296a:	55                   	push   %ebp
8010296b:	89 e5                	mov    %esp,%ebp
8010296d:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102970:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80102977:	e8 ab 25 00 00       	call   80104f27 <acquire>

  if((b = idequeue) == 0){
8010297c:	a1 b4 c8 10 80       	mov    0x8010c8b4,%eax
80102981:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102984:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102988:	75 11                	jne    8010299b <ideintr+0x31>
    release(&idelock);
8010298a:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80102991:	e8 fb 25 00 00       	call   80104f91 <release>
    return;
80102996:	e9 90 00 00 00       	jmp    80102a2b <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010299b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299e:	8b 40 58             	mov    0x58(%eax),%eax
801029a1:	a3 b4 c8 10 80       	mov    %eax,0x8010c8b4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	8b 00                	mov    (%eax),%eax
801029ab:	83 e0 04             	and    $0x4,%eax
801029ae:	85 c0                	test   %eax,%eax
801029b0:	75 2e                	jne    801029e0 <ideintr+0x76>
801029b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801029b9:	e8 47 fd ff ff       	call   80102705 <idewait>
801029be:	85 c0                	test   %eax,%eax
801029c0:	78 1e                	js     801029e0 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801029c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c5:	83 c0 5c             	add    $0x5c,%eax
801029c8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801029cf:	00 
801029d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029d4:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801029db:	e8 bf fc ff ff       	call   8010269f <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801029e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e3:	8b 00                	mov    (%eax),%eax
801029e5:	83 c8 02             	or     $0x2,%eax
801029e8:	89 c2                	mov    %eax,%edx
801029ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ed:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f2:	8b 00                	mov    (%eax),%eax
801029f4:	83 e0 fb             	and    $0xfffffffb,%eax
801029f7:	89 c2                	mov    %eax,%edx
801029f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fc:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a01:	89 04 24             	mov    %eax,(%esp)
80102a04:	e8 24 22 00 00       	call   80104c2d <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a09:	a1 b4 c8 10 80       	mov    0x8010c8b4,%eax
80102a0e:	85 c0                	test   %eax,%eax
80102a10:	74 0d                	je     80102a1f <ideintr+0xb5>
    idestart(idequeue);
80102a12:	a1 b4 c8 10 80       	mov    0x8010c8b4,%eax
80102a17:	89 04 24             	mov    %eax,(%esp)
80102a1a:	e8 c1 fd ff ff       	call   801027e0 <idestart>

  release(&idelock);
80102a1f:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80102a26:	e8 66 25 00 00       	call   80104f91 <release>
}
80102a2b:	c9                   	leave  
80102a2c:	c3                   	ret    

80102a2d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a2d:	55                   	push   %ebp
80102a2e:	89 e5                	mov    %esp,%ebp
80102a30:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102a33:	8b 45 08             	mov    0x8(%ebp),%eax
80102a36:	83 c0 0c             	add    $0xc,%eax
80102a39:	89 04 24             	mov    %eax,(%esp)
80102a3c:	e8 5e 24 00 00       	call   80104e9f <holdingsleep>
80102a41:	85 c0                	test   %eax,%eax
80102a43:	75 0c                	jne    80102a51 <iderw+0x24>
    panic("iderw: buf not locked");
80102a45:	c7 04 24 f2 8c 10 80 	movl   $0x80108cf2,(%esp)
80102a4c:	e8 03 db ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a51:	8b 45 08             	mov    0x8(%ebp),%eax
80102a54:	8b 00                	mov    (%eax),%eax
80102a56:	83 e0 06             	and    $0x6,%eax
80102a59:	83 f8 02             	cmp    $0x2,%eax
80102a5c:	75 0c                	jne    80102a6a <iderw+0x3d>
    panic("iderw: nothing to do");
80102a5e:	c7 04 24 08 8d 10 80 	movl   $0x80108d08,(%esp)
80102a65:	e8 ea da ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a6d:	8b 40 04             	mov    0x4(%eax),%eax
80102a70:	85 c0                	test   %eax,%eax
80102a72:	74 15                	je     80102a89 <iderw+0x5c>
80102a74:	a1 b8 c8 10 80       	mov    0x8010c8b8,%eax
80102a79:	85 c0                	test   %eax,%eax
80102a7b:	75 0c                	jne    80102a89 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102a7d:	c7 04 24 1d 8d 10 80 	movl   $0x80108d1d,(%esp)
80102a84:	e8 cb da ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a89:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80102a90:	e8 92 24 00 00       	call   80104f27 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102a95:	8b 45 08             	mov    0x8(%ebp),%eax
80102a98:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a9f:	c7 45 f4 b4 c8 10 80 	movl   $0x8010c8b4,-0xc(%ebp)
80102aa6:	eb 0b                	jmp    80102ab3 <iderw+0x86>
80102aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aab:	8b 00                	mov    (%eax),%eax
80102aad:	83 c0 58             	add    $0x58,%eax
80102ab0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab6:	8b 00                	mov    (%eax),%eax
80102ab8:	85 c0                	test   %eax,%eax
80102aba:	75 ec                	jne    80102aa8 <iderw+0x7b>
    ;
  *pp = b;
80102abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102ac4:	a1 b4 c8 10 80       	mov    0x8010c8b4,%eax
80102ac9:	3b 45 08             	cmp    0x8(%ebp),%eax
80102acc:	75 0d                	jne    80102adb <iderw+0xae>
    idestart(b);
80102ace:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad1:	89 04 24             	mov    %eax,(%esp)
80102ad4:	e8 07 fd ff ff       	call   801027e0 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ad9:	eb 15                	jmp    80102af0 <iderw+0xc3>
80102adb:	eb 13                	jmp    80102af0 <iderw+0xc3>
    sleep(b, &idelock);
80102add:	c7 44 24 04 80 c8 10 	movl   $0x8010c880,0x4(%esp)
80102ae4:	80 
80102ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae8:	89 04 24             	mov    %eax,(%esp)
80102aeb:	e8 69 20 00 00       	call   80104b59 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102af0:	8b 45 08             	mov    0x8(%ebp),%eax
80102af3:	8b 00                	mov    (%eax),%eax
80102af5:	83 e0 06             	and    $0x6,%eax
80102af8:	83 f8 02             	cmp    $0x2,%eax
80102afb:	75 e0                	jne    80102add <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102afd:	c7 04 24 80 c8 10 80 	movl   $0x8010c880,(%esp)
80102b04:	e8 88 24 00 00       	call   80104f91 <release>
}
80102b09:	c9                   	leave  
80102b0a:	c3                   	ret    
	...

80102b0c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b0c:	55                   	push   %ebp
80102b0d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b0f:	a1 f4 4a 11 80       	mov    0x80114af4,%eax
80102b14:	8b 55 08             	mov    0x8(%ebp),%edx
80102b17:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b19:	a1 f4 4a 11 80       	mov    0x80114af4,%eax
80102b1e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b21:	5d                   	pop    %ebp
80102b22:	c3                   	ret    

80102b23 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b23:	55                   	push   %ebp
80102b24:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b26:	a1 f4 4a 11 80       	mov    0x80114af4,%eax
80102b2b:	8b 55 08             	mov    0x8(%ebp),%edx
80102b2e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b30:	a1 f4 4a 11 80       	mov    0x80114af4,%eax
80102b35:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b38:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b3b:	5d                   	pop    %ebp
80102b3c:	c3                   	ret    

80102b3d <ioapicinit>:

void
ioapicinit(void)
{
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
80102b40:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b43:	c7 05 f4 4a 11 80 00 	movl   $0xfec00000,0x80114af4
80102b4a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102b54:	e8 b3 ff ff ff       	call   80102b0c <ioapicread>
80102b59:	c1 e8 10             	shr    $0x10,%eax
80102b5c:	25 ff 00 00 00       	and    $0xff,%eax
80102b61:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102b6b:	e8 9c ff ff ff       	call   80102b0c <ioapicread>
80102b70:	c1 e8 18             	shr    $0x18,%eax
80102b73:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b76:	a0 20 4c 11 80       	mov    0x80114c20,%al
80102b7b:	0f b6 c0             	movzbl %al,%eax
80102b7e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b81:	74 0c                	je     80102b8f <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b83:	c7 04 24 3c 8d 10 80 	movl   $0x80108d3c,(%esp)
80102b8a:	e8 32 d8 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b96:	eb 3d                	jmp    80102bd5 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9b:	83 c0 20             	add    $0x20,%eax
80102b9e:	0d 00 00 01 00       	or     $0x10000,%eax
80102ba3:	89 c2                	mov    %eax,%edx
80102ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba8:	83 c0 08             	add    $0x8,%eax
80102bab:	01 c0                	add    %eax,%eax
80102bad:	89 54 24 04          	mov    %edx,0x4(%esp)
80102bb1:	89 04 24             	mov    %eax,(%esp)
80102bb4:	e8 6a ff ff ff       	call   80102b23 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbc:	83 c0 08             	add    $0x8,%eax
80102bbf:	01 c0                	add    %eax,%eax
80102bc1:	40                   	inc    %eax
80102bc2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102bc9:	00 
80102bca:	89 04 24             	mov    %eax,(%esp)
80102bcd:	e8 51 ff ff ff       	call   80102b23 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102bd2:	ff 45 f4             	incl   -0xc(%ebp)
80102bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102bdb:	7e bb                	jle    80102b98 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102bdd:	c9                   	leave  
80102bde:	c3                   	ret    

80102bdf <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102bdf:	55                   	push   %ebp
80102be0:	89 e5                	mov    %esp,%ebp
80102be2:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102be5:	8b 45 08             	mov    0x8(%ebp),%eax
80102be8:	83 c0 20             	add    $0x20,%eax
80102beb:	89 c2                	mov    %eax,%edx
80102bed:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf0:	83 c0 08             	add    $0x8,%eax
80102bf3:	01 c0                	add    %eax,%eax
80102bf5:	89 54 24 04          	mov    %edx,0x4(%esp)
80102bf9:	89 04 24             	mov    %eax,(%esp)
80102bfc:	e8 22 ff ff ff       	call   80102b23 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c01:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c04:	c1 e0 18             	shl    $0x18,%eax
80102c07:	8b 55 08             	mov    0x8(%ebp),%edx
80102c0a:	83 c2 08             	add    $0x8,%edx
80102c0d:	01 d2                	add    %edx,%edx
80102c0f:	42                   	inc    %edx
80102c10:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c14:	89 14 24             	mov    %edx,(%esp)
80102c17:	e8 07 ff ff ff       	call   80102b23 <ioapicwrite>
}
80102c1c:	c9                   	leave  
80102c1d:	c3                   	ret    
	...

80102c20 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c20:	55                   	push   %ebp
80102c21:	89 e5                	mov    %esp,%ebp
80102c23:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102c26:	c7 44 24 04 6e 8d 10 	movl   $0x80108d6e,0x4(%esp)
80102c2d:	80 
80102c2e:	c7 04 24 00 4b 11 80 	movl   $0x80114b00,(%esp)
80102c35:	e8 cc 22 00 00       	call   80104f06 <initlock>
  kmem.use_lock = 0;
80102c3a:	c7 05 34 4b 11 80 00 	movl   $0x0,0x80114b34
80102c41:	00 00 00 
  freerange(vstart, vend);
80102c44:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c47:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c4e:	89 04 24             	mov    %eax,(%esp)
80102c51:	e8 26 00 00 00       	call   80102c7c <freerange>
}
80102c56:	c9                   	leave  
80102c57:	c3                   	ret    

80102c58 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c58:	55                   	push   %ebp
80102c59:	89 e5                	mov    %esp,%ebp
80102c5b:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c61:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c65:	8b 45 08             	mov    0x8(%ebp),%eax
80102c68:	89 04 24             	mov    %eax,(%esp)
80102c6b:	e8 0c 00 00 00       	call   80102c7c <freerange>
  kmem.use_lock = 1;
80102c70:	c7 05 34 4b 11 80 01 	movl   $0x1,0x80114b34
80102c77:	00 00 00 
}
80102c7a:	c9                   	leave  
80102c7b:	c3                   	ret    

80102c7c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c7c:	55                   	push   %ebp
80102c7d:	89 e5                	mov    %esp,%ebp
80102c7f:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c82:	8b 45 08             	mov    0x8(%ebp),%eax
80102c85:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c8a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c92:	eb 12                	jmp    80102ca6 <freerange+0x2a>
    kfree(p);
80102c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c97:	89 04 24             	mov    %eax,(%esp)
80102c9a:	e8 16 00 00 00       	call   80102cb5 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c9f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca9:	05 00 10 00 00       	add    $0x1000,%eax
80102cae:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102cb1:	76 e1                	jbe    80102c94 <freerange+0x18>
    kfree(p);
}
80102cb3:	c9                   	leave  
80102cb4:	c3                   	ret    

80102cb5 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cb5:	55                   	push   %ebp
80102cb6:	89 e5                	mov    %esp,%ebp
80102cb8:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cbe:	25 ff 0f 00 00       	and    $0xfff,%eax
80102cc3:	85 c0                	test   %eax,%eax
80102cc5:	75 18                	jne    80102cdf <kfree+0x2a>
80102cc7:	81 7d 08 60 7b 11 80 	cmpl   $0x80117b60,0x8(%ebp)
80102cce:	72 0f                	jb     80102cdf <kfree+0x2a>
80102cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd3:	05 00 00 00 80       	add    $0x80000000,%eax
80102cd8:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102cdd:	76 0c                	jbe    80102ceb <kfree+0x36>
    panic("kfree");
80102cdf:	c7 04 24 73 8d 10 80 	movl   $0x80108d73,(%esp)
80102ce6:	e8 69 d8 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ceb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102cf2:	00 
80102cf3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102cfa:	00 
80102cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cfe:	89 04 24             	mov    %eax,(%esp)
80102d01:	e8 84 24 00 00       	call   8010518a <memset>

  if(kmem.use_lock)
80102d06:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102d0b:	85 c0                	test   %eax,%eax
80102d0d:	74 0c                	je     80102d1b <kfree+0x66>
    acquire(&kmem.lock);
80102d0f:	c7 04 24 00 4b 11 80 	movl   $0x80114b00,(%esp)
80102d16:	e8 0c 22 00 00       	call   80104f27 <acquire>
  r = (struct run*)v;
80102d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102d21:	8b 15 38 4b 11 80    	mov    0x80114b38,%edx
80102d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d2a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d2f:	a3 38 4b 11 80       	mov    %eax,0x80114b38
  if(kmem.use_lock)
80102d34:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102d39:	85 c0                	test   %eax,%eax
80102d3b:	74 0c                	je     80102d49 <kfree+0x94>
    release(&kmem.lock);
80102d3d:	c7 04 24 00 4b 11 80 	movl   $0x80114b00,(%esp)
80102d44:	e8 48 22 00 00       	call   80104f91 <release>
}
80102d49:	c9                   	leave  
80102d4a:	c3                   	ret    

80102d4b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d4b:	55                   	push   %ebp
80102d4c:	89 e5                	mov    %esp,%ebp
80102d4e:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102d51:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102d56:	85 c0                	test   %eax,%eax
80102d58:	74 0c                	je     80102d66 <kalloc+0x1b>
    acquire(&kmem.lock);
80102d5a:	c7 04 24 00 4b 11 80 	movl   $0x80114b00,(%esp)
80102d61:	e8 c1 21 00 00       	call   80104f27 <acquire>
  r = kmem.freelist;
80102d66:	a1 38 4b 11 80       	mov    0x80114b38,%eax
80102d6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d72:	74 0a                	je     80102d7e <kalloc+0x33>
    kmem.freelist = r->next;
80102d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d77:	8b 00                	mov    (%eax),%eax
80102d79:	a3 38 4b 11 80       	mov    %eax,0x80114b38
  if(kmem.use_lock)
80102d7e:	a1 34 4b 11 80       	mov    0x80114b34,%eax
80102d83:	85 c0                	test   %eax,%eax
80102d85:	74 0c                	je     80102d93 <kalloc+0x48>
    release(&kmem.lock);
80102d87:	c7 04 24 00 4b 11 80 	movl   $0x80114b00,(%esp)
80102d8e:	e8 fe 21 00 00       	call   80104f91 <release>
  return (char*)r;
80102d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d96:	c9                   	leave  
80102d97:	c3                   	ret    

80102d98 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d98:	55                   	push   %ebp
80102d99:	89 e5                	mov    %esp,%ebp
80102d9b:	83 ec 14             	sub    $0x14,%esp
80102d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80102da1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102da5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102da8:	89 c2                	mov    %eax,%edx
80102daa:	ec                   	in     (%dx),%al
80102dab:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dae:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102db1:	c9                   	leave  
80102db2:	c3                   	ret    

80102db3 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102db3:	55                   	push   %ebp
80102db4:	89 e5                	mov    %esp,%ebp
80102db6:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102db9:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102dc0:	e8 d3 ff ff ff       	call   80102d98 <inb>
80102dc5:	0f b6 c0             	movzbl %al,%eax
80102dc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dce:	83 e0 01             	and    $0x1,%eax
80102dd1:	85 c0                	test   %eax,%eax
80102dd3:	75 0a                	jne    80102ddf <kbdgetc+0x2c>
    return -1;
80102dd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102dda:	e9 21 01 00 00       	jmp    80102f00 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102ddf:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102de6:	e8 ad ff ff ff       	call   80102d98 <inb>
80102deb:	0f b6 c0             	movzbl %al,%eax
80102dee:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102df1:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102df8:	75 17                	jne    80102e11 <kbdgetc+0x5e>
    shift |= E0ESC;
80102dfa:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102dff:	83 c8 40             	or     $0x40,%eax
80102e02:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
    return 0;
80102e07:	b8 00 00 00 00       	mov    $0x0,%eax
80102e0c:	e9 ef 00 00 00       	jmp    80102f00 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102e11:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e14:	25 80 00 00 00       	and    $0x80,%eax
80102e19:	85 c0                	test   %eax,%eax
80102e1b:	74 44                	je     80102e61 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e1d:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102e22:	83 e0 40             	and    $0x40,%eax
80102e25:	85 c0                	test   %eax,%eax
80102e27:	75 08                	jne    80102e31 <kbdgetc+0x7e>
80102e29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e2c:	83 e0 7f             	and    $0x7f,%eax
80102e2f:	eb 03                	jmp    80102e34 <kbdgetc+0x81>
80102e31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e34:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e37:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e3a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e3f:	8a 00                	mov    (%eax),%al
80102e41:	83 c8 40             	or     $0x40,%eax
80102e44:	0f b6 c0             	movzbl %al,%eax
80102e47:	f7 d0                	not    %eax
80102e49:	89 c2                	mov    %eax,%edx
80102e4b:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102e50:	21 d0                	and    %edx,%eax
80102e52:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
    return 0;
80102e57:	b8 00 00 00 00       	mov    $0x0,%eax
80102e5c:	e9 9f 00 00 00       	jmp    80102f00 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e61:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102e66:	83 e0 40             	and    $0x40,%eax
80102e69:	85 c0                	test   %eax,%eax
80102e6b:	74 14                	je     80102e81 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e6d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e74:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102e79:	83 e0 bf             	and    $0xffffffbf,%eax
80102e7c:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
  }

  shift |= shiftcode[data];
80102e81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e84:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e89:	8a 00                	mov    (%eax),%al
80102e8b:	0f b6 d0             	movzbl %al,%edx
80102e8e:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102e93:	09 d0                	or     %edx,%eax
80102e95:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
  shift ^= togglecode[data];
80102e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e9d:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102ea2:	8a 00                	mov    (%eax),%al
80102ea4:	0f b6 d0             	movzbl %al,%edx
80102ea7:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102eac:	31 d0                	xor    %edx,%eax
80102eae:	a3 bc c8 10 80       	mov    %eax,0x8010c8bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102eb3:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102eb8:	83 e0 03             	and    $0x3,%eax
80102ebb:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102ec2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ec5:	01 d0                	add    %edx,%eax
80102ec7:	8a 00                	mov    (%eax),%al
80102ec9:	0f b6 c0             	movzbl %al,%eax
80102ecc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ecf:	a1 bc c8 10 80       	mov    0x8010c8bc,%eax
80102ed4:	83 e0 08             	and    $0x8,%eax
80102ed7:	85 c0                	test   %eax,%eax
80102ed9:	74 22                	je     80102efd <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102edb:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102edf:	76 0c                	jbe    80102eed <kbdgetc+0x13a>
80102ee1:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ee5:	77 06                	ja     80102eed <kbdgetc+0x13a>
      c += 'A' - 'a';
80102ee7:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102eeb:	eb 10                	jmp    80102efd <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102eed:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102ef1:	76 0a                	jbe    80102efd <kbdgetc+0x14a>
80102ef3:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ef7:	77 04                	ja     80102efd <kbdgetc+0x14a>
      c += 'a' - 'A';
80102ef9:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102efd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f00:	c9                   	leave  
80102f01:	c3                   	ret    

80102f02 <kbdintr>:

void
kbdintr(void)
{
80102f02:	55                   	push   %ebp
80102f03:	89 e5                	mov    %esp,%ebp
80102f05:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102f08:	c7 04 24 b3 2d 10 80 	movl   $0x80102db3,(%esp)
80102f0f:	e8 e1 d8 ff ff       	call   801007f5 <consoleintr>
}
80102f14:	c9                   	leave  
80102f15:	c3                   	ret    
	...

80102f18 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102f18:	55                   	push   %ebp
80102f19:	89 e5                	mov    %esp,%ebp
80102f1b:	83 ec 14             	sub    $0x14,%esp
80102f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80102f21:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f28:	89 c2                	mov    %eax,%edx
80102f2a:	ec                   	in     (%dx),%al
80102f2b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f2e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102f31:	c9                   	leave  
80102f32:	c3                   	ret    

80102f33 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f33:	55                   	push   %ebp
80102f34:	89 e5                	mov    %esp,%ebp
80102f36:	83 ec 08             	sub    $0x8,%esp
80102f39:	8b 45 08             	mov    0x8(%ebp),%eax
80102f3c:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f3f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102f43:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f46:	8a 45 f8             	mov    -0x8(%ebp),%al
80102f49:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102f4c:	ee                   	out    %al,(%dx)
}
80102f4d:	c9                   	leave  
80102f4e:	c3                   	ret    

80102f4f <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102f4f:	55                   	push   %ebp
80102f50:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f52:	a1 3c 4b 11 80       	mov    0x80114b3c,%eax
80102f57:	8b 55 08             	mov    0x8(%ebp),%edx
80102f5a:	c1 e2 02             	shl    $0x2,%edx
80102f5d:	01 c2                	add    %eax,%edx
80102f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f62:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f64:	a1 3c 4b 11 80       	mov    0x80114b3c,%eax
80102f69:	83 c0 20             	add    $0x20,%eax
80102f6c:	8b 00                	mov    (%eax),%eax
}
80102f6e:	5d                   	pop    %ebp
80102f6f:	c3                   	ret    

80102f70 <lapicinit>:

void
lapicinit(void)
{
80102f70:	55                   	push   %ebp
80102f71:	89 e5                	mov    %esp,%ebp
80102f73:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102f76:	a1 3c 4b 11 80       	mov    0x80114b3c,%eax
80102f7b:	85 c0                	test   %eax,%eax
80102f7d:	75 05                	jne    80102f84 <lapicinit+0x14>
    return;
80102f7f:	e9 43 01 00 00       	jmp    801030c7 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f84:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102f8b:	00 
80102f8c:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102f93:	e8 b7 ff ff ff       	call   80102f4f <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f98:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102f9f:	00 
80102fa0:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102fa7:	e8 a3 ff ff ff       	call   80102f4f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102fac:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102fb3:	00 
80102fb4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fbb:	e8 8f ff ff ff       	call   80102f4f <lapicw>
  lapicw(TICR, 10000000);
80102fc0:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102fc7:	00 
80102fc8:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102fcf:	e8 7b ff ff ff       	call   80102f4f <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102fd4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102fdb:	00 
80102fdc:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102fe3:	e8 67 ff ff ff       	call   80102f4f <lapicw>
  lapicw(LINT1, MASKED);
80102fe8:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102fef:	00 
80102ff0:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102ff7:	e8 53 ff ff ff       	call   80102f4f <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102ffc:	a1 3c 4b 11 80       	mov    0x80114b3c,%eax
80103001:	83 c0 30             	add    $0x30,%eax
80103004:	8b 00                	mov    (%eax),%eax
80103006:	c1 e8 10             	shr    $0x10,%eax
80103009:	0f b6 c0             	movzbl %al,%eax
8010300c:	83 f8 03             	cmp    $0x3,%eax
8010300f:	76 14                	jbe    80103025 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80103011:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103018:	00 
80103019:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103020:	e8 2a ff ff ff       	call   80102f4f <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103025:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
8010302c:	00 
8010302d:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103034:	e8 16 ff ff ff       	call   80102f4f <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103039:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103040:	00 
80103041:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103048:	e8 02 ff ff ff       	call   80102f4f <lapicw>
  lapicw(ESR, 0);
8010304d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103054:	00 
80103055:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010305c:	e8 ee fe ff ff       	call   80102f4f <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103068:	00 
80103069:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103070:	e8 da fe ff ff       	call   80102f4f <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103075:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010307c:	00 
8010307d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103084:	e8 c6 fe ff ff       	call   80102f4f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103089:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103090:	00 
80103091:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103098:	e8 b2 fe ff ff       	call   80102f4f <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010309d:	90                   	nop
8010309e:	a1 3c 4b 11 80       	mov    0x80114b3c,%eax
801030a3:	05 00 03 00 00       	add    $0x300,%eax
801030a8:	8b 00                	mov    (%eax),%eax
801030aa:	25 00 10 00 00       	and    $0x1000,%eax
801030af:	85 c0                	test   %eax,%eax
801030b1:	75 eb                	jne    8010309e <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030ba:	00 
801030bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801030c2:	e8 88 fe ff ff       	call   80102f4f <lapicw>
}
801030c7:	c9                   	leave  
801030c8:	c3                   	ret    

801030c9 <lapicid>:

int
lapicid(void)
{
801030c9:	55                   	push   %ebp
801030ca:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801030cc:	a1 3c 4b 11 80       	mov    0x80114b3c,%eax
801030d1:	85 c0                	test   %eax,%eax
801030d3:	75 07                	jne    801030dc <lapicid+0x13>
    return 0;
801030d5:	b8 00 00 00 00       	mov    $0x0,%eax
801030da:	eb 0d                	jmp    801030e9 <lapicid+0x20>
  return lapic[ID] >> 24;
801030dc:	a1 3c 4b 11 80       	mov    0x80114b3c,%eax
801030e1:	83 c0 20             	add    $0x20,%eax
801030e4:	8b 00                	mov    (%eax),%eax
801030e6:	c1 e8 18             	shr    $0x18,%eax
}
801030e9:	5d                   	pop    %ebp
801030ea:	c3                   	ret    

801030eb <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030eb:	55                   	push   %ebp
801030ec:	89 e5                	mov    %esp,%ebp
801030ee:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801030f1:	a1 3c 4b 11 80       	mov    0x80114b3c,%eax
801030f6:	85 c0                	test   %eax,%eax
801030f8:	74 14                	je     8010310e <lapiceoi+0x23>
    lapicw(EOI, 0);
801030fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103101:	00 
80103102:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103109:	e8 41 fe ff ff       	call   80102f4f <lapicw>
}
8010310e:	c9                   	leave  
8010310f:	c3                   	ret    

80103110 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103110:	55                   	push   %ebp
80103111:	89 e5                	mov    %esp,%ebp
}
80103113:	5d                   	pop    %ebp
80103114:	c3                   	ret    

80103115 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103115:	55                   	push   %ebp
80103116:	89 e5                	mov    %esp,%ebp
80103118:	83 ec 1c             	sub    $0x1c,%esp
8010311b:	8b 45 08             	mov    0x8(%ebp),%eax
8010311e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103121:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103128:	00 
80103129:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103130:	e8 fe fd ff ff       	call   80102f33 <outb>
  outb(CMOS_PORT+1, 0x0A);
80103135:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010313c:	00 
8010313d:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103144:	e8 ea fd ff ff       	call   80102f33 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103149:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103150:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103153:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103158:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010315b:	8d 50 02             	lea    0x2(%eax),%edx
8010315e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103161:	c1 e8 04             	shr    $0x4,%eax
80103164:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103167:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010316b:	c1 e0 18             	shl    $0x18,%eax
8010316e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103172:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103179:	e8 d1 fd ff ff       	call   80102f4f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010317e:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103185:	00 
80103186:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010318d:	e8 bd fd ff ff       	call   80102f4f <lapicw>
  microdelay(200);
80103192:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103199:	e8 72 ff ff ff       	call   80103110 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010319e:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801031a5:	00 
801031a6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031ad:	e8 9d fd ff ff       	call   80102f4f <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031b2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801031b9:	e8 52 ff ff ff       	call   80103110 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031c5:	eb 3f                	jmp    80103206 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
801031c7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031cb:	c1 e0 18             	shl    $0x18,%eax
801031ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801031d2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031d9:	e8 71 fd ff ff       	call   80102f4f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801031de:	8b 45 0c             	mov    0xc(%ebp),%eax
801031e1:	c1 e8 0c             	shr    $0xc,%eax
801031e4:	80 cc 06             	or     $0x6,%ah
801031e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801031eb:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031f2:	e8 58 fd ff ff       	call   80102f4f <lapicw>
    microdelay(200);
801031f7:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031fe:	e8 0d ff ff ff       	call   80103110 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103203:	ff 45 fc             	incl   -0x4(%ebp)
80103206:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010320a:	7e bb                	jle    801031c7 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010320c:	c9                   	leave  
8010320d:	c3                   	ret    

8010320e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010320e:	55                   	push   %ebp
8010320f:	89 e5                	mov    %esp,%ebp
80103211:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103214:	8b 45 08             	mov    0x8(%ebp),%eax
80103217:	0f b6 c0             	movzbl %al,%eax
8010321a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010321e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103225:	e8 09 fd ff ff       	call   80102f33 <outb>
  microdelay(200);
8010322a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103231:	e8 da fe ff ff       	call   80103110 <microdelay>

  return inb(CMOS_RETURN);
80103236:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010323d:	e8 d6 fc ff ff       	call   80102f18 <inb>
80103242:	0f b6 c0             	movzbl %al,%eax
}
80103245:	c9                   	leave  
80103246:	c3                   	ret    

80103247 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103247:	55                   	push   %ebp
80103248:	89 e5                	mov    %esp,%ebp
8010324a:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010324d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103254:	e8 b5 ff ff ff       	call   8010320e <cmos_read>
80103259:	8b 55 08             	mov    0x8(%ebp),%edx
8010325c:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010325e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103265:	e8 a4 ff ff ff       	call   8010320e <cmos_read>
8010326a:	8b 55 08             	mov    0x8(%ebp),%edx
8010326d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103270:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103277:	e8 92 ff ff ff       	call   8010320e <cmos_read>
8010327c:	8b 55 08             	mov    0x8(%ebp),%edx
8010327f:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103282:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103289:	e8 80 ff ff ff       	call   8010320e <cmos_read>
8010328e:	8b 55 08             	mov    0x8(%ebp),%edx
80103291:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103294:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010329b:	e8 6e ff ff ff       	call   8010320e <cmos_read>
801032a0:	8b 55 08             	mov    0x8(%ebp),%edx
801032a3:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801032a6:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801032ad:	e8 5c ff ff ff       	call   8010320e <cmos_read>
801032b2:	8b 55 08             	mov    0x8(%ebp),%edx
801032b5:	89 42 14             	mov    %eax,0x14(%edx)
}
801032b8:	c9                   	leave  
801032b9:	c3                   	ret    

801032ba <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801032ba:	55                   	push   %ebp
801032bb:	89 e5                	mov    %esp,%ebp
801032bd:	57                   	push   %edi
801032be:	56                   	push   %esi
801032bf:	53                   	push   %ebx
801032c0:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032c3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801032ca:	e8 3f ff ff ff       	call   8010320e <cmos_read>
801032cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801032d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032d5:	83 e0 04             	and    $0x4,%eax
801032d8:	85 c0                	test   %eax,%eax
801032da:	0f 94 c0             	sete   %al
801032dd:	0f b6 c0             	movzbl %al,%eax
801032e0:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801032e3:	8d 45 c8             	lea    -0x38(%ebp),%eax
801032e6:	89 04 24             	mov    %eax,(%esp)
801032e9:	e8 59 ff ff ff       	call   80103247 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801032ee:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801032f5:	e8 14 ff ff ff       	call   8010320e <cmos_read>
801032fa:	25 80 00 00 00       	and    $0x80,%eax
801032ff:	85 c0                	test   %eax,%eax
80103301:	74 02                	je     80103305 <cmostime+0x4b>
        continue;
80103303:	eb 36                	jmp    8010333b <cmostime+0x81>
    fill_rtcdate(&t2);
80103305:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103308:	89 04 24             	mov    %eax,(%esp)
8010330b:	e8 37 ff ff ff       	call   80103247 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103310:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103317:	00 
80103318:	8d 45 b0             	lea    -0x50(%ebp),%eax
8010331b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010331f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103322:	89 04 24             	mov    %eax,(%esp)
80103325:	e8 d7 1e 00 00       	call   80105201 <memcmp>
8010332a:	85 c0                	test   %eax,%eax
8010332c:	75 0d                	jne    8010333b <cmostime+0x81>
      break;
8010332e:	90                   	nop
  }

  // convert
  if(bcd) {
8010332f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80103333:	0f 84 ac 00 00 00    	je     801033e5 <cmostime+0x12b>
80103339:	eb 02                	jmp    8010333d <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010333b:	eb a6                	jmp    801032e3 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010333d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80103340:	c1 e8 04             	shr    $0x4,%eax
80103343:	89 c2                	mov    %eax,%edx
80103345:	89 d0                	mov    %edx,%eax
80103347:	c1 e0 02             	shl    $0x2,%eax
8010334a:	01 d0                	add    %edx,%eax
8010334c:	01 c0                	add    %eax,%eax
8010334e:	8b 55 c8             	mov    -0x38(%ebp),%edx
80103351:	83 e2 0f             	and    $0xf,%edx
80103354:	01 d0                	add    %edx,%eax
80103356:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103359:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010335c:	c1 e8 04             	shr    $0x4,%eax
8010335f:	89 c2                	mov    %eax,%edx
80103361:	89 d0                	mov    %edx,%eax
80103363:	c1 e0 02             	shl    $0x2,%eax
80103366:	01 d0                	add    %edx,%eax
80103368:	01 c0                	add    %eax,%eax
8010336a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010336d:	83 e2 0f             	and    $0xf,%edx
80103370:	01 d0                	add    %edx,%eax
80103372:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103375:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103378:	c1 e8 04             	shr    $0x4,%eax
8010337b:	89 c2                	mov    %eax,%edx
8010337d:	89 d0                	mov    %edx,%eax
8010337f:	c1 e0 02             	shl    $0x2,%eax
80103382:	01 d0                	add    %edx,%eax
80103384:	01 c0                	add    %eax,%eax
80103386:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103389:	83 e2 0f             	and    $0xf,%edx
8010338c:	01 d0                	add    %edx,%eax
8010338e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103391:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103394:	c1 e8 04             	shr    $0x4,%eax
80103397:	89 c2                	mov    %eax,%edx
80103399:	89 d0                	mov    %edx,%eax
8010339b:	c1 e0 02             	shl    $0x2,%eax
8010339e:	01 d0                	add    %edx,%eax
801033a0:	01 c0                	add    %eax,%eax
801033a2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801033a5:	83 e2 0f             	and    $0xf,%edx
801033a8:	01 d0                	add    %edx,%eax
801033aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
801033ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033b0:	c1 e8 04             	shr    $0x4,%eax
801033b3:	89 c2                	mov    %eax,%edx
801033b5:	89 d0                	mov    %edx,%eax
801033b7:	c1 e0 02             	shl    $0x2,%eax
801033ba:	01 d0                	add    %edx,%eax
801033bc:	01 c0                	add    %eax,%eax
801033be:	8b 55 d8             	mov    -0x28(%ebp),%edx
801033c1:	83 e2 0f             	and    $0xf,%edx
801033c4:	01 d0                	add    %edx,%eax
801033c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
801033c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801033cc:	c1 e8 04             	shr    $0x4,%eax
801033cf:	89 c2                	mov    %eax,%edx
801033d1:	89 d0                	mov    %edx,%eax
801033d3:	c1 e0 02             	shl    $0x2,%eax
801033d6:	01 d0                	add    %edx,%eax
801033d8:	01 c0                	add    %eax,%eax
801033da:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033dd:	83 e2 0f             	and    $0xf,%edx
801033e0:	01 d0                	add    %edx,%eax
801033e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
801033e5:	8b 45 08             	mov    0x8(%ebp),%eax
801033e8:	89 c2                	mov    %eax,%edx
801033ea:	8d 5d c8             	lea    -0x38(%ebp),%ebx
801033ed:	b8 06 00 00 00       	mov    $0x6,%eax
801033f2:	89 d7                	mov    %edx,%edi
801033f4:	89 de                	mov    %ebx,%esi
801033f6:	89 c1                	mov    %eax,%ecx
801033f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801033fa:	8b 45 08             	mov    0x8(%ebp),%eax
801033fd:	8b 40 14             	mov    0x14(%eax),%eax
80103400:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103406:	8b 45 08             	mov    0x8(%ebp),%eax
80103409:	89 50 14             	mov    %edx,0x14(%eax)
}
8010340c:	83 c4 5c             	add    $0x5c,%esp
8010340f:	5b                   	pop    %ebx
80103410:	5e                   	pop    %esi
80103411:	5f                   	pop    %edi
80103412:	5d                   	pop    %ebp
80103413:	c3                   	ret    

80103414 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103414:	55                   	push   %ebp
80103415:	89 e5                	mov    %esp,%ebp
80103417:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010341a:	c7 44 24 04 79 8d 10 	movl   $0x80108d79,0x4(%esp)
80103421:	80 
80103422:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80103429:	e8 d8 1a 00 00       	call   80104f06 <initlock>
  readsb(dev, &sb);
8010342e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103431:	89 44 24 04          	mov    %eax,0x4(%esp)
80103435:	8b 45 08             	mov    0x8(%ebp),%eax
80103438:	89 04 24             	mov    %eax,(%esp)
8010343b:	e8 d8 e0 ff ff       	call   80101518 <readsb>
  log.start = sb.logstart;
80103440:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103443:	a3 74 4b 11 80       	mov    %eax,0x80114b74
  log.size = sb.nlog;
80103448:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010344b:	a3 78 4b 11 80       	mov    %eax,0x80114b78
  log.dev = dev;
80103450:	8b 45 08             	mov    0x8(%ebp),%eax
80103453:	a3 84 4b 11 80       	mov    %eax,0x80114b84
  recover_from_log();
80103458:	e8 95 01 00 00       	call   801035f2 <recover_from_log>
}
8010345d:	c9                   	leave  
8010345e:	c3                   	ret    

8010345f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010345f:	55                   	push   %ebp
80103460:	89 e5                	mov    %esp,%ebp
80103462:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103465:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010346c:	e9 89 00 00 00       	jmp    801034fa <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103471:	8b 15 74 4b 11 80    	mov    0x80114b74,%edx
80103477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010347a:	01 d0                	add    %edx,%eax
8010347c:	40                   	inc    %eax
8010347d:	89 c2                	mov    %eax,%edx
8010347f:	a1 84 4b 11 80       	mov    0x80114b84,%eax
80103484:	89 54 24 04          	mov    %edx,0x4(%esp)
80103488:	89 04 24             	mov    %eax,(%esp)
8010348b:	e8 25 cd ff ff       	call   801001b5 <bread>
80103490:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103496:	83 c0 10             	add    $0x10,%eax
80103499:	8b 04 85 4c 4b 11 80 	mov    -0x7feeb4b4(,%eax,4),%eax
801034a0:	89 c2                	mov    %eax,%edx
801034a2:	a1 84 4b 11 80       	mov    0x80114b84,%eax
801034a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801034ab:	89 04 24             	mov    %eax,(%esp)
801034ae:	e8 02 cd ff ff       	call   801001b5 <bread>
801034b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b9:	8d 50 5c             	lea    0x5c(%eax),%edx
801034bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034bf:	83 c0 5c             	add    $0x5c,%eax
801034c2:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801034c9:	00 
801034ca:	89 54 24 04          	mov    %edx,0x4(%esp)
801034ce:	89 04 24             	mov    %eax,(%esp)
801034d1:	e8 7d 1d 00 00       	call   80105253 <memmove>
    bwrite(dbuf);  // write dst to disk
801034d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d9:	89 04 24             	mov    %eax,(%esp)
801034dc:	e8 0b cd ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
801034e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034e4:	89 04 24             	mov    %eax,(%esp)
801034e7:	e8 40 cd ff ff       	call   8010022c <brelse>
    brelse(dbuf);
801034ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ef:	89 04 24             	mov    %eax,(%esp)
801034f2:	e8 35 cd ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034f7:	ff 45 f4             	incl   -0xc(%ebp)
801034fa:	a1 88 4b 11 80       	mov    0x80114b88,%eax
801034ff:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103502:	0f 8f 69 ff ff ff    	jg     80103471 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103508:	c9                   	leave  
80103509:	c3                   	ret    

8010350a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010350a:	55                   	push   %ebp
8010350b:	89 e5                	mov    %esp,%ebp
8010350d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103510:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80103515:	89 c2                	mov    %eax,%edx
80103517:	a1 84 4b 11 80       	mov    0x80114b84,%eax
8010351c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103520:	89 04 24             	mov    %eax,(%esp)
80103523:	e8 8d cc ff ff       	call   801001b5 <bread>
80103528:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010352b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010352e:	83 c0 5c             	add    $0x5c,%eax
80103531:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103534:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103537:	8b 00                	mov    (%eax),%eax
80103539:	a3 88 4b 11 80       	mov    %eax,0x80114b88
  for (i = 0; i < log.lh.n; i++) {
8010353e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103545:	eb 1a                	jmp    80103561 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103547:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010354a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010354d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103551:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103554:	83 c2 10             	add    $0x10,%edx
80103557:	89 04 95 4c 4b 11 80 	mov    %eax,-0x7feeb4b4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010355e:	ff 45 f4             	incl   -0xc(%ebp)
80103561:	a1 88 4b 11 80       	mov    0x80114b88,%eax
80103566:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103569:	7f dc                	jg     80103547 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010356b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356e:	89 04 24             	mov    %eax,(%esp)
80103571:	e8 b6 cc ff ff       	call   8010022c <brelse>
}
80103576:	c9                   	leave  
80103577:	c3                   	ret    

80103578 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103578:	55                   	push   %ebp
80103579:	89 e5                	mov    %esp,%ebp
8010357b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010357e:	a1 74 4b 11 80       	mov    0x80114b74,%eax
80103583:	89 c2                	mov    %eax,%edx
80103585:	a1 84 4b 11 80       	mov    0x80114b84,%eax
8010358a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010358e:	89 04 24             	mov    %eax,(%esp)
80103591:	e8 1f cc ff ff       	call   801001b5 <bread>
80103596:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103599:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010359c:	83 c0 5c             	add    $0x5c,%eax
8010359f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801035a2:	8b 15 88 4b 11 80    	mov    0x80114b88,%edx
801035a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035ab:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801035ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035b4:	eb 1a                	jmp    801035d0 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801035b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035b9:	83 c0 10             	add    $0x10,%eax
801035bc:	8b 0c 85 4c 4b 11 80 	mov    -0x7feeb4b4(,%eax,4),%ecx
801035c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035c9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801035cd:	ff 45 f4             	incl   -0xc(%ebp)
801035d0:	a1 88 4b 11 80       	mov    0x80114b88,%eax
801035d5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035d8:	7f dc                	jg     801035b6 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801035da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035dd:	89 04 24             	mov    %eax,(%esp)
801035e0:	e8 07 cc ff ff       	call   801001ec <bwrite>
  brelse(buf);
801035e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035e8:	89 04 24             	mov    %eax,(%esp)
801035eb:	e8 3c cc ff ff       	call   8010022c <brelse>
}
801035f0:	c9                   	leave  
801035f1:	c3                   	ret    

801035f2 <recover_from_log>:

static void
recover_from_log(void)
{
801035f2:	55                   	push   %ebp
801035f3:	89 e5                	mov    %esp,%ebp
801035f5:	83 ec 08             	sub    $0x8,%esp
  read_head();
801035f8:	e8 0d ff ff ff       	call   8010350a <read_head>
  install_trans(); // if committed, copy from log to disk
801035fd:	e8 5d fe ff ff       	call   8010345f <install_trans>
  log.lh.n = 0;
80103602:	c7 05 88 4b 11 80 00 	movl   $0x0,0x80114b88
80103609:	00 00 00 
  write_head(); // clear the log
8010360c:	e8 67 ff ff ff       	call   80103578 <write_head>
}
80103611:	c9                   	leave  
80103612:	c3                   	ret    

80103613 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103613:	55                   	push   %ebp
80103614:	89 e5                	mov    %esp,%ebp
80103616:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103619:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80103620:	e8 02 19 00 00       	call   80104f27 <acquire>
  while(1){
    if(log.committing){
80103625:	a1 80 4b 11 80       	mov    0x80114b80,%eax
8010362a:	85 c0                	test   %eax,%eax
8010362c:	74 16                	je     80103644 <begin_op+0x31>
      sleep(&log, &log.lock);
8010362e:	c7 44 24 04 40 4b 11 	movl   $0x80114b40,0x4(%esp)
80103635:	80 
80103636:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
8010363d:	e8 17 15 00 00       	call   80104b59 <sleep>
80103642:	eb 4d                	jmp    80103691 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103644:	8b 15 88 4b 11 80    	mov    0x80114b88,%edx
8010364a:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
8010364f:	8d 48 01             	lea    0x1(%eax),%ecx
80103652:	89 c8                	mov    %ecx,%eax
80103654:	c1 e0 02             	shl    $0x2,%eax
80103657:	01 c8                	add    %ecx,%eax
80103659:	01 c0                	add    %eax,%eax
8010365b:	01 d0                	add    %edx,%eax
8010365d:	83 f8 1e             	cmp    $0x1e,%eax
80103660:	7e 16                	jle    80103678 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103662:	c7 44 24 04 40 4b 11 	movl   $0x80114b40,0x4(%esp)
80103669:	80 
8010366a:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80103671:	e8 e3 14 00 00       	call   80104b59 <sleep>
80103676:	eb 19                	jmp    80103691 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103678:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
8010367d:	40                   	inc    %eax
8010367e:	a3 7c 4b 11 80       	mov    %eax,0x80114b7c
      release(&log.lock);
80103683:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
8010368a:	e8 02 19 00 00       	call   80104f91 <release>
      break;
8010368f:	eb 02                	jmp    80103693 <begin_op+0x80>
    }
  }
80103691:	eb 92                	jmp    80103625 <begin_op+0x12>
}
80103693:	c9                   	leave  
80103694:	c3                   	ret    

80103695 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103695:	55                   	push   %ebp
80103696:	89 e5                	mov    %esp,%ebp
80103698:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010369b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801036a2:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
801036a9:	e8 79 18 00 00       	call   80104f27 <acquire>
  log.outstanding -= 1;
801036ae:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801036b3:	48                   	dec    %eax
801036b4:	a3 7c 4b 11 80       	mov    %eax,0x80114b7c
  if(log.committing)
801036b9:	a1 80 4b 11 80       	mov    0x80114b80,%eax
801036be:	85 c0                	test   %eax,%eax
801036c0:	74 0c                	je     801036ce <end_op+0x39>
    panic("log.committing");
801036c2:	c7 04 24 7d 8d 10 80 	movl   $0x80108d7d,(%esp)
801036c9:	e8 86 ce ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
801036ce:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
801036d3:	85 c0                	test   %eax,%eax
801036d5:	75 13                	jne    801036ea <end_op+0x55>
    do_commit = 1;
801036d7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036de:	c7 05 80 4b 11 80 01 	movl   $0x1,0x80114b80
801036e5:	00 00 00 
801036e8:	eb 0c                	jmp    801036f6 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801036ea:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
801036f1:	e8 37 15 00 00       	call   80104c2d <wakeup>
  }
  release(&log.lock);
801036f6:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
801036fd:	e8 8f 18 00 00       	call   80104f91 <release>

  if(do_commit){
80103702:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103706:	74 33                	je     8010373b <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103708:	e8 db 00 00 00       	call   801037e8 <commit>
    acquire(&log.lock);
8010370d:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80103714:	e8 0e 18 00 00       	call   80104f27 <acquire>
    log.committing = 0;
80103719:	c7 05 80 4b 11 80 00 	movl   $0x0,0x80114b80
80103720:	00 00 00 
    wakeup(&log);
80103723:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
8010372a:	e8 fe 14 00 00       	call   80104c2d <wakeup>
    release(&log.lock);
8010372f:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
80103736:	e8 56 18 00 00       	call   80104f91 <release>
  }
}
8010373b:	c9                   	leave  
8010373c:	c3                   	ret    

8010373d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010373d:	55                   	push   %ebp
8010373e:	89 e5                	mov    %esp,%ebp
80103740:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103743:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010374a:	e9 89 00 00 00       	jmp    801037d8 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010374f:	8b 15 74 4b 11 80    	mov    0x80114b74,%edx
80103755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103758:	01 d0                	add    %edx,%eax
8010375a:	40                   	inc    %eax
8010375b:	89 c2                	mov    %eax,%edx
8010375d:	a1 84 4b 11 80       	mov    0x80114b84,%eax
80103762:	89 54 24 04          	mov    %edx,0x4(%esp)
80103766:	89 04 24             	mov    %eax,(%esp)
80103769:	e8 47 ca ff ff       	call   801001b5 <bread>
8010376e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103774:	83 c0 10             	add    $0x10,%eax
80103777:	8b 04 85 4c 4b 11 80 	mov    -0x7feeb4b4(,%eax,4),%eax
8010377e:	89 c2                	mov    %eax,%edx
80103780:	a1 84 4b 11 80       	mov    0x80114b84,%eax
80103785:	89 54 24 04          	mov    %edx,0x4(%esp)
80103789:	89 04 24             	mov    %eax,(%esp)
8010378c:	e8 24 ca ff ff       	call   801001b5 <bread>
80103791:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103794:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103797:	8d 50 5c             	lea    0x5c(%eax),%edx
8010379a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010379d:	83 c0 5c             	add    $0x5c,%eax
801037a0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801037a7:	00 
801037a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801037ac:	89 04 24             	mov    %eax,(%esp)
801037af:	e8 9f 1a 00 00       	call   80105253 <memmove>
    bwrite(to);  // write the log
801037b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037b7:	89 04 24             	mov    %eax,(%esp)
801037ba:	e8 2d ca ff ff       	call   801001ec <bwrite>
    brelse(from);
801037bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037c2:	89 04 24             	mov    %eax,(%esp)
801037c5:	e8 62 ca ff ff       	call   8010022c <brelse>
    brelse(to);
801037ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037cd:	89 04 24             	mov    %eax,(%esp)
801037d0:	e8 57 ca ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037d5:	ff 45 f4             	incl   -0xc(%ebp)
801037d8:	a1 88 4b 11 80       	mov    0x80114b88,%eax
801037dd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037e0:	0f 8f 69 ff ff ff    	jg     8010374f <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
801037e6:	c9                   	leave  
801037e7:	c3                   	ret    

801037e8 <commit>:

static void
commit()
{
801037e8:	55                   	push   %ebp
801037e9:	89 e5                	mov    %esp,%ebp
801037eb:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037ee:	a1 88 4b 11 80       	mov    0x80114b88,%eax
801037f3:	85 c0                	test   %eax,%eax
801037f5:	7e 1e                	jle    80103815 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801037f7:	e8 41 ff ff ff       	call   8010373d <write_log>
    write_head();    // Write header to disk -- the real commit
801037fc:	e8 77 fd ff ff       	call   80103578 <write_head>
    install_trans(); // Now install writes to home locations
80103801:	e8 59 fc ff ff       	call   8010345f <install_trans>
    log.lh.n = 0;
80103806:	c7 05 88 4b 11 80 00 	movl   $0x0,0x80114b88
8010380d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103810:	e8 63 fd ff ff       	call   80103578 <write_head>
  }
}
80103815:	c9                   	leave  
80103816:	c3                   	ret    

80103817 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103817:	55                   	push   %ebp
80103818:	89 e5                	mov    %esp,%ebp
8010381a:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010381d:	a1 88 4b 11 80       	mov    0x80114b88,%eax
80103822:	83 f8 1d             	cmp    $0x1d,%eax
80103825:	7f 10                	jg     80103837 <log_write+0x20>
80103827:	a1 88 4b 11 80       	mov    0x80114b88,%eax
8010382c:	8b 15 78 4b 11 80    	mov    0x80114b78,%edx
80103832:	4a                   	dec    %edx
80103833:	39 d0                	cmp    %edx,%eax
80103835:	7c 0c                	jl     80103843 <log_write+0x2c>
    panic("too big a transaction");
80103837:	c7 04 24 8c 8d 10 80 	movl   $0x80108d8c,(%esp)
8010383e:	e8 11 cd ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103843:	a1 7c 4b 11 80       	mov    0x80114b7c,%eax
80103848:	85 c0                	test   %eax,%eax
8010384a:	7f 0c                	jg     80103858 <log_write+0x41>
    panic("log_write outside of trans");
8010384c:	c7 04 24 a2 8d 10 80 	movl   $0x80108da2,(%esp)
80103853:	e8 fc cc ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103858:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
8010385f:	e8 c3 16 00 00       	call   80104f27 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103864:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010386b:	eb 1e                	jmp    8010388b <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010386d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103870:	83 c0 10             	add    $0x10,%eax
80103873:	8b 04 85 4c 4b 11 80 	mov    -0x7feeb4b4(,%eax,4),%eax
8010387a:	89 c2                	mov    %eax,%edx
8010387c:	8b 45 08             	mov    0x8(%ebp),%eax
8010387f:	8b 40 08             	mov    0x8(%eax),%eax
80103882:	39 c2                	cmp    %eax,%edx
80103884:	75 02                	jne    80103888 <log_write+0x71>
      break;
80103886:	eb 0d                	jmp    80103895 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103888:	ff 45 f4             	incl   -0xc(%ebp)
8010388b:	a1 88 4b 11 80       	mov    0x80114b88,%eax
80103890:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103893:	7f d8                	jg     8010386d <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103895:	8b 45 08             	mov    0x8(%ebp),%eax
80103898:	8b 40 08             	mov    0x8(%eax),%eax
8010389b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010389e:	83 c2 10             	add    $0x10,%edx
801038a1:	89 04 95 4c 4b 11 80 	mov    %eax,-0x7feeb4b4(,%edx,4)
  if (i == log.lh.n)
801038a8:	a1 88 4b 11 80       	mov    0x80114b88,%eax
801038ad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038b0:	75 0b                	jne    801038bd <log_write+0xa6>
    log.lh.n++;
801038b2:	a1 88 4b 11 80       	mov    0x80114b88,%eax
801038b7:	40                   	inc    %eax
801038b8:	a3 88 4b 11 80       	mov    %eax,0x80114b88
  b->flags |= B_DIRTY; // prevent eviction
801038bd:	8b 45 08             	mov    0x8(%ebp),%eax
801038c0:	8b 00                	mov    (%eax),%eax
801038c2:	83 c8 04             	or     $0x4,%eax
801038c5:	89 c2                	mov    %eax,%edx
801038c7:	8b 45 08             	mov    0x8(%ebp),%eax
801038ca:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038cc:	c7 04 24 40 4b 11 80 	movl   $0x80114b40,(%esp)
801038d3:	e8 b9 16 00 00       	call   80104f91 <release>
}
801038d8:	c9                   	leave  
801038d9:	c3                   	ret    
	...

801038dc <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801038dc:	55                   	push   %ebp
801038dd:	89 e5                	mov    %esp,%ebp
801038df:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038e2:	8b 55 08             	mov    0x8(%ebp),%edx
801038e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801038e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038eb:	f0 87 02             	lock xchg %eax,(%edx)
801038ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038f4:	c9                   	leave  
801038f5:	c3                   	ret    

801038f6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038f6:	55                   	push   %ebp
801038f7:	89 e5                	mov    %esp,%ebp
801038f9:	83 e4 f0             	and    $0xfffffff0,%esp
801038fc:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038ff:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103906:	80 
80103907:	c7 04 24 60 7b 11 80 	movl   $0x80117b60,(%esp)
8010390e:	e8 0d f3 ff ff       	call   80102c20 <kinit1>
  kvmalloc();      // kernel page table
80103913:	e8 2b 45 00 00       	call   80107e43 <kvmalloc>
  mpinit();        // detect other processors
80103918:	e8 c4 03 00 00       	call   80103ce1 <mpinit>
  lapicinit();     // interrupt controller
8010391d:	e8 4e f6 ff ff       	call   80102f70 <lapicinit>
  seginit();       // segment descriptors
80103922:	e8 04 40 00 00       	call   8010792b <seginit>
  picinit();       // disable pic
80103927:	e8 04 05 00 00       	call   80103e30 <picinit>
  ioapicinit();    // another interrupt controller
8010392c:	e8 0c f2 ff ff       	call   80102b3d <ioapicinit>
  consoleinit();   // console hardware
80103931:	e8 a1 d2 ff ff       	call   80100bd7 <consoleinit>
  uartinit();      // serial port
80103936:	e8 7c 33 00 00       	call   80106cb7 <uartinit>
  pinit();         // process table
8010393b:	e8 e6 08 00 00       	call   80104226 <pinit>
  tvinit();        // trap vectors
80103940:	e8 3f 2f 00 00       	call   80106884 <tvinit>
  binit();         // buffer cache
80103945:	e8 ea c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010394a:	e8 7f d7 ff ff       	call   801010ce <fileinit>
  ideinit();       // disk 
8010394f:	e8 f5 ed ff ff       	call   80102749 <ideinit>
  startothers();   // start other processors
80103954:	e8 83 00 00 00       	call   801039dc <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103959:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103960:	8e 
80103961:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103968:	e8 eb f2 ff ff       	call   80102c58 <kinit2>
  userinit();      // first user process
8010396d:	e8 ce 0a 00 00       	call   80104440 <userinit>
  mpmain();        // finish this processor's setup
80103972:	e8 1a 00 00 00       	call   80103991 <mpmain>

80103977 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103977:	55                   	push   %ebp
80103978:	89 e5                	mov    %esp,%ebp
8010397a:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
8010397d:	e8 d8 44 00 00       	call   80107e5a <switchkvm>
  seginit();
80103982:	e8 a4 3f 00 00       	call   8010792b <seginit>
  lapicinit();
80103987:	e8 e4 f5 ff ff       	call   80102f70 <lapicinit>
  mpmain();
8010398c:	e8 00 00 00 00       	call   80103991 <mpmain>

80103991 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103991:	55                   	push   %ebp
80103992:	89 e5                	mov    %esp,%ebp
80103994:	53                   	push   %ebx
80103995:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103998:	e8 a5 08 00 00       	call   80104242 <cpuid>
8010399d:	89 c3                	mov    %eax,%ebx
8010399f:	e8 9e 08 00 00       	call   80104242 <cpuid>
801039a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801039a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801039ac:	c7 04 24 bd 8d 10 80 	movl   $0x80108dbd,(%esp)
801039b3:	e8 09 ca ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
801039b8:	e8 24 30 00 00       	call   801069e1 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801039bd:	e8 c5 08 00 00       	call   80104287 <mycpu>
801039c2:	05 a0 00 00 00       	add    $0xa0,%eax
801039c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801039ce:	00 
801039cf:	89 04 24             	mov    %eax,(%esp)
801039d2:	e8 05 ff ff ff       	call   801038dc <xchg>
  scheduler();     // start running processes
801039d7:	e8 b3 0f 00 00       	call   8010498f <scheduler>

801039dc <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039dc:	55                   	push   %ebp
801039dd:	89 e5                	mov    %esp,%ebp
801039df:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801039e2:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039e9:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039ee:	89 44 24 08          	mov    %eax,0x8(%esp)
801039f2:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
801039f9:	80 
801039fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039fd:	89 04 24             	mov    %eax,(%esp)
80103a00:	e8 4e 18 00 00       	call   80105253 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103a05:	c7 45 f4 40 4c 11 80 	movl   $0x80114c40,-0xc(%ebp)
80103a0c:	eb 75                	jmp    80103a83 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103a0e:	e8 74 08 00 00       	call   80104287 <mycpu>
80103a13:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a16:	75 02                	jne    80103a1a <startothers+0x3e>
      continue;
80103a18:	eb 62                	jmp    80103a7c <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a1a:	e8 2c f3 ff ff       	call   80102d4b <kalloc>
80103a1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a25:	83 e8 04             	sub    $0x4,%eax
80103a28:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a2b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a31:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a36:	83 e8 08             	sub    $0x8,%eax
80103a39:	c7 00 77 39 10 80    	movl   $0x80103977,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a42:	8d 50 f4             	lea    -0xc(%eax),%edx
80103a45:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103a4a:	05 00 00 00 80       	add    $0x80000000,%eax
80103a4f:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a54:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5d:	8a 00                	mov    (%eax),%al
80103a5f:	0f b6 c0             	movzbl %al,%eax
80103a62:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a66:	89 04 24             	mov    %eax,(%esp)
80103a69:	e8 a7 f6 ff ff       	call   80103115 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a6e:	90                   	nop
80103a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a72:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103a78:	85 c0                	test   %eax,%eax
80103a7a:	74 f3                	je     80103a6f <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a7c:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103a83:	a1 c0 51 11 80       	mov    0x801151c0,%eax
80103a88:	89 c2                	mov    %eax,%edx
80103a8a:	89 d0                	mov    %edx,%eax
80103a8c:	c1 e0 02             	shl    $0x2,%eax
80103a8f:	01 d0                	add    %edx,%eax
80103a91:	01 c0                	add    %eax,%eax
80103a93:	01 d0                	add    %edx,%eax
80103a95:	c1 e0 04             	shl    $0x4,%eax
80103a98:	05 40 4c 11 80       	add    $0x80114c40,%eax
80103a9d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103aa0:	0f 87 68 ff ff ff    	ja     80103a0e <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103aa6:	c9                   	leave  
80103aa7:	c3                   	ret    

80103aa8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103aa8:	55                   	push   %ebp
80103aa9:	89 e5                	mov    %esp,%ebp
80103aab:	83 ec 14             	sub    $0x14,%esp
80103aae:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ab8:	89 c2                	mov    %eax,%edx
80103aba:	ec                   	in     (%dx),%al
80103abb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103abe:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103ac1:	c9                   	leave  
80103ac2:	c3                   	ret    

80103ac3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ac3:	55                   	push   %ebp
80103ac4:	89 e5                	mov    %esp,%ebp
80103ac6:	83 ec 08             	sub    $0x8,%esp
80103ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80103acc:	8b 55 0c             	mov    0xc(%ebp),%edx
80103acf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103ad3:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ad6:	8a 45 f8             	mov    -0x8(%ebp),%al
80103ad9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103adc:	ee                   	out    %al,(%dx)
}
80103add:	c9                   	leave  
80103ade:	c3                   	ret    

80103adf <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103adf:	55                   	push   %ebp
80103ae0:	89 e5                	mov    %esp,%ebp
80103ae2:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103ae5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103aec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103af3:	eb 13                	jmp    80103b08 <sum+0x29>
    sum += addr[i];
80103af5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103af8:	8b 45 08             	mov    0x8(%ebp),%eax
80103afb:	01 d0                	add    %edx,%eax
80103afd:	8a 00                	mov    (%eax),%al
80103aff:	0f b6 c0             	movzbl %al,%eax
80103b02:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103b05:	ff 45 fc             	incl   -0x4(%ebp)
80103b08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b0b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b0e:	7c e5                	jl     80103af5 <sum+0x16>
    sum += addr[i];
  return sum;
80103b10:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b13:	c9                   	leave  
80103b14:	c3                   	ret    

80103b15 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b15:	55                   	push   %ebp
80103b16:	89 e5                	mov    %esp,%ebp
80103b18:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b1e:	05 00 00 00 80       	add    $0x80000000,%eax
80103b23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b26:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2c:	01 d0                	add    %edx,%eax
80103b2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b37:	eb 3f                	jmp    80103b78 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b39:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b40:	00 
80103b41:	c7 44 24 04 d4 8d 10 	movl   $0x80108dd4,0x4(%esp)
80103b48:	80 
80103b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4c:	89 04 24             	mov    %eax,(%esp)
80103b4f:	e8 ad 16 00 00       	call   80105201 <memcmp>
80103b54:	85 c0                	test   %eax,%eax
80103b56:	75 1c                	jne    80103b74 <mpsearch1+0x5f>
80103b58:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103b5f:	00 
80103b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b63:	89 04 24             	mov    %eax,(%esp)
80103b66:	e8 74 ff ff ff       	call   80103adf <sum>
80103b6b:	84 c0                	test   %al,%al
80103b6d:	75 05                	jne    80103b74 <mpsearch1+0x5f>
      return (struct mp*)p;
80103b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b72:	eb 11                	jmp    80103b85 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b74:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b7e:	72 b9                	jb     80103b39 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b85:	c9                   	leave  
80103b86:	c3                   	ret    

80103b87 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b87:	55                   	push   %ebp
80103b88:	89 e5                	mov    %esp,%ebp
80103b8a:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b8d:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b97:	83 c0 0f             	add    $0xf,%eax
80103b9a:	8a 00                	mov    (%eax),%al
80103b9c:	0f b6 c0             	movzbl %al,%eax
80103b9f:	c1 e0 08             	shl    $0x8,%eax
80103ba2:	89 c2                	mov    %eax,%edx
80103ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba7:	83 c0 0e             	add    $0xe,%eax
80103baa:	8a 00                	mov    (%eax),%al
80103bac:	0f b6 c0             	movzbl %al,%eax
80103baf:	09 d0                	or     %edx,%eax
80103bb1:	c1 e0 04             	shl    $0x4,%eax
80103bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bbb:	74 21                	je     80103bde <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103bbd:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103bc4:	00 
80103bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc8:	89 04 24             	mov    %eax,(%esp)
80103bcb:	e8 45 ff ff ff       	call   80103b15 <mpsearch1>
80103bd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bd7:	74 4e                	je     80103c27 <mpsearch+0xa0>
      return mp;
80103bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bdc:	eb 5d                	jmp    80103c3b <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be1:	83 c0 14             	add    $0x14,%eax
80103be4:	8a 00                	mov    (%eax),%al
80103be6:	0f b6 c0             	movzbl %al,%eax
80103be9:	c1 e0 08             	shl    $0x8,%eax
80103bec:	89 c2                	mov    %eax,%edx
80103bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf1:	83 c0 13             	add    $0x13,%eax
80103bf4:	8a 00                	mov    (%eax),%al
80103bf6:	0f b6 c0             	movzbl %al,%eax
80103bf9:	09 d0                	or     %edx,%eax
80103bfb:	c1 e0 0a             	shl    $0xa,%eax
80103bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c04:	2d 00 04 00 00       	sub    $0x400,%eax
80103c09:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c10:	00 
80103c11:	89 04 24             	mov    %eax,(%esp)
80103c14:	e8 fc fe ff ff       	call   80103b15 <mpsearch1>
80103c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c1c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c20:	74 05                	je     80103c27 <mpsearch+0xa0>
      return mp;
80103c22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c25:	eb 14                	jmp    80103c3b <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c27:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103c2e:	00 
80103c2f:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103c36:	e8 da fe ff ff       	call   80103b15 <mpsearch1>
}
80103c3b:	c9                   	leave  
80103c3c:	c3                   	ret    

80103c3d <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c3d:	55                   	push   %ebp
80103c3e:	89 e5                	mov    %esp,%ebp
80103c40:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c43:	e8 3f ff ff ff       	call   80103b87 <mpsearch>
80103c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c4f:	74 0a                	je     80103c5b <mpconfig+0x1e>
80103c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c54:	8b 40 04             	mov    0x4(%eax),%eax
80103c57:	85 c0                	test   %eax,%eax
80103c59:	75 07                	jne    80103c62 <mpconfig+0x25>
    return 0;
80103c5b:	b8 00 00 00 00       	mov    $0x0,%eax
80103c60:	eb 7d                	jmp    80103cdf <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c65:	8b 40 04             	mov    0x4(%eax),%eax
80103c68:	05 00 00 00 80       	add    $0x80000000,%eax
80103c6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c70:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103c77:	00 
80103c78:	c7 44 24 04 d9 8d 10 	movl   $0x80108dd9,0x4(%esp)
80103c7f:	80 
80103c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c83:	89 04 24             	mov    %eax,(%esp)
80103c86:	e8 76 15 00 00       	call   80105201 <memcmp>
80103c8b:	85 c0                	test   %eax,%eax
80103c8d:	74 07                	je     80103c96 <mpconfig+0x59>
    return 0;
80103c8f:	b8 00 00 00 00       	mov    $0x0,%eax
80103c94:	eb 49                	jmp    80103cdf <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c99:	8a 40 06             	mov    0x6(%eax),%al
80103c9c:	3c 01                	cmp    $0x1,%al
80103c9e:	74 11                	je     80103cb1 <mpconfig+0x74>
80103ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca3:	8a 40 06             	mov    0x6(%eax),%al
80103ca6:	3c 04                	cmp    $0x4,%al
80103ca8:	74 07                	je     80103cb1 <mpconfig+0x74>
    return 0;
80103caa:	b8 00 00 00 00       	mov    $0x0,%eax
80103caf:	eb 2e                	jmp    80103cdf <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb4:	8b 40 04             	mov    0x4(%eax),%eax
80103cb7:	0f b7 c0             	movzwl %ax,%eax
80103cba:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc1:	89 04 24             	mov    %eax,(%esp)
80103cc4:	e8 16 fe ff ff       	call   80103adf <sum>
80103cc9:	84 c0                	test   %al,%al
80103ccb:	74 07                	je     80103cd4 <mpconfig+0x97>
    return 0;
80103ccd:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd2:	eb 0b                	jmp    80103cdf <mpconfig+0xa2>
  *pmp = mp;
80103cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cda:	89 10                	mov    %edx,(%eax)
  return conf;
80103cdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103cdf:	c9                   	leave  
80103ce0:	c3                   	ret    

80103ce1 <mpinit>:

void
mpinit(void)
{
80103ce1:	55                   	push   %ebp
80103ce2:	89 e5                	mov    %esp,%ebp
80103ce4:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103ce7:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103cea:	89 04 24             	mov    %eax,(%esp)
80103ced:	e8 4b ff ff ff       	call   80103c3d <mpconfig>
80103cf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cf5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cf9:	75 0c                	jne    80103d07 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103cfb:	c7 04 24 de 8d 10 80 	movl   $0x80108dde,(%esp)
80103d02:	e8 4d c8 ff ff       	call   80100554 <panic>
  ismp = 1;
80103d07:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d11:	8b 40 24             	mov    0x24(%eax),%eax
80103d14:	a3 3c 4b 11 80       	mov    %eax,0x80114b3c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d1c:	83 c0 2c             	add    $0x2c,%eax
80103d1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d25:	8b 40 04             	mov    0x4(%eax),%eax
80103d28:	0f b7 d0             	movzwl %ax,%edx
80103d2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d2e:	01 d0                	add    %edx,%eax
80103d30:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103d33:	eb 7d                	jmp    80103db2 <mpinit+0xd1>
    switch(*p){
80103d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d38:	8a 00                	mov    (%eax),%al
80103d3a:	0f b6 c0             	movzbl %al,%eax
80103d3d:	83 f8 04             	cmp    $0x4,%eax
80103d40:	77 68                	ja     80103daa <mpinit+0xc9>
80103d42:	8b 04 85 18 8e 10 80 	mov    -0x7fef71e8(,%eax,4),%eax
80103d49:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103d51:	a1 c0 51 11 80       	mov    0x801151c0,%eax
80103d56:	83 f8 07             	cmp    $0x7,%eax
80103d59:	7f 2c                	jg     80103d87 <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d5b:	8b 15 c0 51 11 80    	mov    0x801151c0,%edx
80103d61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d64:	8a 48 01             	mov    0x1(%eax),%cl
80103d67:	89 d0                	mov    %edx,%eax
80103d69:	c1 e0 02             	shl    $0x2,%eax
80103d6c:	01 d0                	add    %edx,%eax
80103d6e:	01 c0                	add    %eax,%eax
80103d70:	01 d0                	add    %edx,%eax
80103d72:	c1 e0 04             	shl    $0x4,%eax
80103d75:	05 40 4c 11 80       	add    $0x80114c40,%eax
80103d7a:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103d7c:	a1 c0 51 11 80       	mov    0x801151c0,%eax
80103d81:	40                   	inc    %eax
80103d82:	a3 c0 51 11 80       	mov    %eax,0x801151c0
      }
      p += sizeof(struct mpproc);
80103d87:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d8b:	eb 25                	jmp    80103db2 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d90:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103d93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d96:	8a 40 01             	mov    0x1(%eax),%al
80103d99:	a2 20 4c 11 80       	mov    %al,0x80114c20
      p += sizeof(struct mpioapic);
80103d9e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103da2:	eb 0e                	jmp    80103db2 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103da4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103da8:	eb 08                	jmp    80103db2 <mpinit+0xd1>
    default:
      ismp = 0;
80103daa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103db1:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db5:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103db8:	0f 82 77 ff ff ff    	jb     80103d35 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103dbe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dc2:	75 0c                	jne    80103dd0 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103dc4:	c7 04 24 f8 8d 10 80 	movl   $0x80108df8,(%esp)
80103dcb:	e8 84 c7 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103dd0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd3:	8a 40 0c             	mov    0xc(%eax),%al
80103dd6:	84 c0                	test   %al,%al
80103dd8:	74 36                	je     80103e10 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dda:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103de1:	00 
80103de2:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103de9:	e8 d5 fc ff ff       	call   80103ac3 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103dee:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103df5:	e8 ae fc ff ff       	call   80103aa8 <inb>
80103dfa:	83 c8 01             	or     $0x1,%eax
80103dfd:	0f b6 c0             	movzbl %al,%eax
80103e00:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e04:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e0b:	e8 b3 fc ff ff       	call   80103ac3 <outb>
  }
}
80103e10:	c9                   	leave  
80103e11:	c3                   	ret    
	...

80103e14 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e14:	55                   	push   %ebp
80103e15:	89 e5                	mov    %esp,%ebp
80103e17:	83 ec 08             	sub    $0x8,%esp
80103e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e20:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103e24:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e27:	8a 45 f8             	mov    -0x8(%ebp),%al
80103e2a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103e2d:	ee                   	out    %al,(%dx)
}
80103e2e:	c9                   	leave  
80103e2f:	c3                   	ret    

80103e30 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103e30:	55                   	push   %ebp
80103e31:	89 e5                	mov    %esp,%ebp
80103e33:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e36:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e3d:	00 
80103e3e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e45:	e8 ca ff ff ff       	call   80103e14 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e4a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e51:	00 
80103e52:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e59:	e8 b6 ff ff ff       	call   80103e14 <outb>
}
80103e5e:	c9                   	leave  
80103e5f:	c3                   	ret    

80103e60 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e60:	55                   	push   %ebp
80103e61:	89 e5                	mov    %esp,%ebp
80103e63:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103e66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103e76:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e79:	8b 10                	mov    (%eax),%edx
80103e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103e80:	e8 65 d2 ff ff       	call   801010ea <filealloc>
80103e85:	8b 55 08             	mov    0x8(%ebp),%edx
80103e88:	89 02                	mov    %eax,(%edx)
80103e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8d:	8b 00                	mov    (%eax),%eax
80103e8f:	85 c0                	test   %eax,%eax
80103e91:	0f 84 c8 00 00 00    	je     80103f5f <pipealloc+0xff>
80103e97:	e8 4e d2 ff ff       	call   801010ea <filealloc>
80103e9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e9f:	89 02                	mov    %eax,(%edx)
80103ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea4:	8b 00                	mov    (%eax),%eax
80103ea6:	85 c0                	test   %eax,%eax
80103ea8:	0f 84 b1 00 00 00    	je     80103f5f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103eae:	e8 98 ee ff ff       	call   80102d4b <kalloc>
80103eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103eb6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103eba:	75 05                	jne    80103ec1 <pipealloc+0x61>
    goto bad;
80103ebc:	e9 9e 00 00 00       	jmp    80103f5f <pipealloc+0xff>
  p->readopen = 1;
80103ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec4:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ecb:	00 00 00 
  p->writeopen = 1;
80103ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed1:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ed8:	00 00 00 
  p->nwrite = 0;
80103edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ede:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ee5:	00 00 00 
  p->nread = 0;
80103ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eeb:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ef2:	00 00 00 
  initlock(&p->lock, "pipe");
80103ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ef8:	c7 44 24 04 2c 8e 10 	movl   $0x80108e2c,0x4(%esp)
80103eff:	80 
80103f00:	89 04 24             	mov    %eax,(%esp)
80103f03:	e8 fe 0f 00 00       	call   80104f06 <initlock>
  (*f0)->type = FD_PIPE;
80103f08:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0b:	8b 00                	mov    (%eax),%eax
80103f0d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f13:	8b 45 08             	mov    0x8(%ebp),%eax
80103f16:	8b 00                	mov    (%eax),%eax
80103f18:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103f1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1f:	8b 00                	mov    (%eax),%eax
80103f21:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103f25:	8b 45 08             	mov    0x8(%ebp),%eax
80103f28:	8b 00                	mov    (%eax),%eax
80103f2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f2d:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103f30:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f33:	8b 00                	mov    (%eax),%eax
80103f35:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f3e:	8b 00                	mov    (%eax),%eax
80103f40:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103f44:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f47:	8b 00                	mov    (%eax),%eax
80103f49:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f50:	8b 00                	mov    (%eax),%eax
80103f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f55:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f58:	b8 00 00 00 00       	mov    $0x0,%eax
80103f5d:	eb 42                	jmp    80103fa1 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103f5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f63:	74 0b                	je     80103f70 <pipealloc+0x110>
    kfree((char*)p);
80103f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f68:	89 04 24             	mov    %eax,(%esp)
80103f6b:	e8 45 ed ff ff       	call   80102cb5 <kfree>
  if(*f0)
80103f70:	8b 45 08             	mov    0x8(%ebp),%eax
80103f73:	8b 00                	mov    (%eax),%eax
80103f75:	85 c0                	test   %eax,%eax
80103f77:	74 0d                	je     80103f86 <pipealloc+0x126>
    fileclose(*f0);
80103f79:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7c:	8b 00                	mov    (%eax),%eax
80103f7e:	89 04 24             	mov    %eax,(%esp)
80103f81:	e8 0c d2 ff ff       	call   80101192 <fileclose>
  if(*f1)
80103f86:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f89:	8b 00                	mov    (%eax),%eax
80103f8b:	85 c0                	test   %eax,%eax
80103f8d:	74 0d                	je     80103f9c <pipealloc+0x13c>
    fileclose(*f1);
80103f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f92:	8b 00                	mov    (%eax),%eax
80103f94:	89 04 24             	mov    %eax,(%esp)
80103f97:	e8 f6 d1 ff ff       	call   80101192 <fileclose>
  return -1;
80103f9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fa1:	c9                   	leave  
80103fa2:	c3                   	ret    

80103fa3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103fa3:	55                   	push   %ebp
80103fa4:	89 e5                	mov    %esp,%ebp
80103fa6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fac:	89 04 24             	mov    %eax,(%esp)
80103faf:	e8 73 0f 00 00       	call   80104f27 <acquire>
  if(writable){
80103fb4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103fb8:	74 1f                	je     80103fd9 <pipeclose+0x36>
    p->writeopen = 0;
80103fba:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103fc4:	00 00 00 
    wakeup(&p->nread);
80103fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fca:	05 34 02 00 00       	add    $0x234,%eax
80103fcf:	89 04 24             	mov    %eax,(%esp)
80103fd2:	e8 56 0c 00 00       	call   80104c2d <wakeup>
80103fd7:	eb 1d                	jmp    80103ff6 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdc:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103fe3:	00 00 00 
    wakeup(&p->nwrite);
80103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe9:	05 38 02 00 00       	add    $0x238,%eax
80103fee:	89 04 24             	mov    %eax,(%esp)
80103ff1:	e8 37 0c 00 00       	call   80104c2d <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff9:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103fff:	85 c0                	test   %eax,%eax
80104001:	75 25                	jne    80104028 <pipeclose+0x85>
80104003:	8b 45 08             	mov    0x8(%ebp),%eax
80104006:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010400c:	85 c0                	test   %eax,%eax
8010400e:	75 18                	jne    80104028 <pipeclose+0x85>
    release(&p->lock);
80104010:	8b 45 08             	mov    0x8(%ebp),%eax
80104013:	89 04 24             	mov    %eax,(%esp)
80104016:	e8 76 0f 00 00       	call   80104f91 <release>
    kfree((char*)p);
8010401b:	8b 45 08             	mov    0x8(%ebp),%eax
8010401e:	89 04 24             	mov    %eax,(%esp)
80104021:	e8 8f ec ff ff       	call   80102cb5 <kfree>
80104026:	eb 0b                	jmp    80104033 <pipeclose+0x90>
  } else
    release(&p->lock);
80104028:	8b 45 08             	mov    0x8(%ebp),%eax
8010402b:	89 04 24             	mov    %eax,(%esp)
8010402e:	e8 5e 0f 00 00       	call   80104f91 <release>
}
80104033:	c9                   	leave  
80104034:	c3                   	ret    

80104035 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104035:	55                   	push   %ebp
80104036:	89 e5                	mov    %esp,%ebp
80104038:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
8010403b:	8b 45 08             	mov    0x8(%ebp),%eax
8010403e:	89 04 24             	mov    %eax,(%esp)
80104041:	e8 e1 0e 00 00       	call   80104f27 <acquire>
  for(i = 0; i < n; i++){
80104046:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010404d:	e9 a3 00 00 00       	jmp    801040f5 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104052:	eb 56                	jmp    801040aa <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80104054:	8b 45 08             	mov    0x8(%ebp),%eax
80104057:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010405d:	85 c0                	test   %eax,%eax
8010405f:	74 0c                	je     8010406d <pipewrite+0x38>
80104061:	e8 a5 02 00 00       	call   8010430b <myproc>
80104066:	8b 40 24             	mov    0x24(%eax),%eax
80104069:	85 c0                	test   %eax,%eax
8010406b:	74 15                	je     80104082 <pipewrite+0x4d>
        release(&p->lock);
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	89 04 24             	mov    %eax,(%esp)
80104073:	e8 19 0f 00 00       	call   80104f91 <release>
        return -1;
80104078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010407d:	e9 9d 00 00 00       	jmp    8010411f <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104082:	8b 45 08             	mov    0x8(%ebp),%eax
80104085:	05 34 02 00 00       	add    $0x234,%eax
8010408a:	89 04 24             	mov    %eax,(%esp)
8010408d:	e8 9b 0b 00 00       	call   80104c2d <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104092:	8b 45 08             	mov    0x8(%ebp),%eax
80104095:	8b 55 08             	mov    0x8(%ebp),%edx
80104098:	81 c2 38 02 00 00    	add    $0x238,%edx
8010409e:	89 44 24 04          	mov    %eax,0x4(%esp)
801040a2:	89 14 24             	mov    %edx,(%esp)
801040a5:	e8 af 0a 00 00       	call   80104b59 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801040b3:	8b 45 08             	mov    0x8(%ebp),%eax
801040b6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040bc:	05 00 02 00 00       	add    $0x200,%eax
801040c1:	39 c2                	cmp    %eax,%edx
801040c3:	74 8f                	je     80104054 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801040c5:	8b 45 08             	mov    0x8(%ebp),%eax
801040c8:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040ce:	8d 48 01             	lea    0x1(%eax),%ecx
801040d1:	8b 55 08             	mov    0x8(%ebp),%edx
801040d4:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801040da:	25 ff 01 00 00       	and    $0x1ff,%eax
801040df:	89 c1                	mov    %eax,%ecx
801040e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e7:	01 d0                	add    %edx,%eax
801040e9:	8a 10                	mov    (%eax),%dl
801040eb:	8b 45 08             	mov    0x8(%ebp),%eax
801040ee:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801040f2:	ff 45 f4             	incl   -0xc(%ebp)
801040f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f8:	3b 45 10             	cmp    0x10(%ebp),%eax
801040fb:	0f 8c 51 ff ff ff    	jl     80104052 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104101:	8b 45 08             	mov    0x8(%ebp),%eax
80104104:	05 34 02 00 00       	add    $0x234,%eax
80104109:	89 04 24             	mov    %eax,(%esp)
8010410c:	e8 1c 0b 00 00       	call   80104c2d <wakeup>
  release(&p->lock);
80104111:	8b 45 08             	mov    0x8(%ebp),%eax
80104114:	89 04 24             	mov    %eax,(%esp)
80104117:	e8 75 0e 00 00       	call   80104f91 <release>
  return n;
8010411c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010411f:	c9                   	leave  
80104120:	c3                   	ret    

80104121 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104121:	55                   	push   %ebp
80104122:	89 e5                	mov    %esp,%ebp
80104124:	53                   	push   %ebx
80104125:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104128:	8b 45 08             	mov    0x8(%ebp),%eax
8010412b:	89 04 24             	mov    %eax,(%esp)
8010412e:	e8 f4 0d 00 00       	call   80104f27 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104133:	eb 39                	jmp    8010416e <piperead+0x4d>
    if(myproc()->killed){
80104135:	e8 d1 01 00 00       	call   8010430b <myproc>
8010413a:	8b 40 24             	mov    0x24(%eax),%eax
8010413d:	85 c0                	test   %eax,%eax
8010413f:	74 15                	je     80104156 <piperead+0x35>
      release(&p->lock);
80104141:	8b 45 08             	mov    0x8(%ebp),%eax
80104144:	89 04 24             	mov    %eax,(%esp)
80104147:	e8 45 0e 00 00       	call   80104f91 <release>
      return -1;
8010414c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104151:	e9 b3 00 00 00       	jmp    80104209 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104156:	8b 45 08             	mov    0x8(%ebp),%eax
80104159:	8b 55 08             	mov    0x8(%ebp),%edx
8010415c:	81 c2 34 02 00 00    	add    $0x234,%edx
80104162:	89 44 24 04          	mov    %eax,0x4(%esp)
80104166:	89 14 24             	mov    %edx,(%esp)
80104169:	e8 eb 09 00 00       	call   80104b59 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010416e:	8b 45 08             	mov    0x8(%ebp),%eax
80104171:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104177:	8b 45 08             	mov    0x8(%ebp),%eax
8010417a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104180:	39 c2                	cmp    %eax,%edx
80104182:	75 0d                	jne    80104191 <piperead+0x70>
80104184:	8b 45 08             	mov    0x8(%ebp),%eax
80104187:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010418d:	85 c0                	test   %eax,%eax
8010418f:	75 a4                	jne    80104135 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104191:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104198:	eb 49                	jmp    801041e3 <piperead+0xc2>
    if(p->nread == p->nwrite)
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041ac:	39 c2                	cmp    %eax,%edx
801041ae:	75 02                	jne    801041b2 <piperead+0x91>
      break;
801041b0:	eb 39                	jmp    801041eb <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801041b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b8:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801041bb:	8b 45 08             	mov    0x8(%ebp),%eax
801041be:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041c4:	8d 48 01             	lea    0x1(%eax),%ecx
801041c7:	8b 55 08             	mov    0x8(%ebp),%edx
801041ca:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801041d0:	25 ff 01 00 00       	and    $0x1ff,%eax
801041d5:	89 c2                	mov    %eax,%edx
801041d7:	8b 45 08             	mov    0x8(%ebp),%eax
801041da:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
801041de:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041e0:	ff 45 f4             	incl   -0xc(%ebp)
801041e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e6:	3b 45 10             	cmp    0x10(%ebp),%eax
801041e9:	7c af                	jl     8010419a <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801041eb:	8b 45 08             	mov    0x8(%ebp),%eax
801041ee:	05 38 02 00 00       	add    $0x238,%eax
801041f3:	89 04 24             	mov    %eax,(%esp)
801041f6:	e8 32 0a 00 00       	call   80104c2d <wakeup>
  release(&p->lock);
801041fb:	8b 45 08             	mov    0x8(%ebp),%eax
801041fe:	89 04 24             	mov    %eax,(%esp)
80104201:	e8 8b 0d 00 00       	call   80104f91 <release>
  return i;
80104206:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104209:	83 c4 24             	add    $0x24,%esp
8010420c:	5b                   	pop    %ebx
8010420d:	5d                   	pop    %ebp
8010420e:	c3                   	ret    
	...

80104210 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104210:	55                   	push   %ebp
80104211:	89 e5                	mov    %esp,%ebp
80104213:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104216:	9c                   	pushf  
80104217:	58                   	pop    %eax
80104218:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010421b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010421e:	c9                   	leave  
8010421f:	c3                   	ret    

80104220 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104220:	55                   	push   %ebp
80104221:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104223:	fb                   	sti    
}
80104224:	5d                   	pop    %ebp
80104225:	c3                   	ret    

80104226 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104226:	55                   	push   %ebp
80104227:	89 e5                	mov    %esp,%ebp
80104229:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
8010422c:	c7 44 24 04 34 8e 10 	movl   $0x80108e34,0x4(%esp)
80104233:	80 
80104234:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
8010423b:	e8 c6 0c 00 00       	call   80104f06 <initlock>
}
80104240:	c9                   	leave  
80104241:	c3                   	ret    

80104242 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104242:	55                   	push   %ebp
80104243:	89 e5                	mov    %esp,%ebp
80104245:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104248:	e8 3a 00 00 00       	call   80104287 <mycpu>
8010424d:	89 c2                	mov    %eax,%edx
8010424f:	b8 40 4c 11 80       	mov    $0x80114c40,%eax
80104254:	29 c2                	sub    %eax,%edx
80104256:	89 d0                	mov    %edx,%eax
80104258:	c1 f8 04             	sar    $0x4,%eax
8010425b:	89 c1                	mov    %eax,%ecx
8010425d:	89 ca                	mov    %ecx,%edx
8010425f:	c1 e2 03             	shl    $0x3,%edx
80104262:	01 ca                	add    %ecx,%edx
80104264:	89 d0                	mov    %edx,%eax
80104266:	c1 e0 05             	shl    $0x5,%eax
80104269:	29 d0                	sub    %edx,%eax
8010426b:	c1 e0 02             	shl    $0x2,%eax
8010426e:	01 c8                	add    %ecx,%eax
80104270:	c1 e0 03             	shl    $0x3,%eax
80104273:	01 c8                	add    %ecx,%eax
80104275:	89 c2                	mov    %eax,%edx
80104277:	c1 e2 0f             	shl    $0xf,%edx
8010427a:	29 c2                	sub    %eax,%edx
8010427c:	c1 e2 02             	shl    $0x2,%edx
8010427f:	01 ca                	add    %ecx,%edx
80104281:	89 d0                	mov    %edx,%eax
80104283:	f7 d8                	neg    %eax
}
80104285:	c9                   	leave  
80104286:	c3                   	ret    

80104287 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104287:	55                   	push   %ebp
80104288:	89 e5                	mov    %esp,%ebp
8010428a:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010428d:	e8 7e ff ff ff       	call   80104210 <readeflags>
80104292:	25 00 02 00 00       	and    $0x200,%eax
80104297:	85 c0                	test   %eax,%eax
80104299:	74 0c                	je     801042a7 <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
8010429b:	c7 04 24 3c 8e 10 80 	movl   $0x80108e3c,(%esp)
801042a2:	e8 ad c2 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
801042a7:	e8 1d ee ff ff       	call   801030c9 <lapicid>
801042ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042b6:	eb 3b                	jmp    801042f3 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
801042b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042bb:	89 d0                	mov    %edx,%eax
801042bd:	c1 e0 02             	shl    $0x2,%eax
801042c0:	01 d0                	add    %edx,%eax
801042c2:	01 c0                	add    %eax,%eax
801042c4:	01 d0                	add    %edx,%eax
801042c6:	c1 e0 04             	shl    $0x4,%eax
801042c9:	05 40 4c 11 80       	add    $0x80114c40,%eax
801042ce:	8a 00                	mov    (%eax),%al
801042d0:	0f b6 c0             	movzbl %al,%eax
801042d3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801042d6:	75 18                	jne    801042f0 <mycpu+0x69>
      return &cpus[i];
801042d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042db:	89 d0                	mov    %edx,%eax
801042dd:	c1 e0 02             	shl    $0x2,%eax
801042e0:	01 d0                	add    %edx,%eax
801042e2:	01 c0                	add    %eax,%eax
801042e4:	01 d0                	add    %edx,%eax
801042e6:	c1 e0 04             	shl    $0x4,%eax
801042e9:	05 40 4c 11 80       	add    $0x80114c40,%eax
801042ee:	eb 19                	jmp    80104309 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801042f0:	ff 45 f4             	incl   -0xc(%ebp)
801042f3:	a1 c0 51 11 80       	mov    0x801151c0,%eax
801042f8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801042fb:	7c bb                	jl     801042b8 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
801042fd:	c7 04 24 62 8e 10 80 	movl   $0x80108e62,(%esp)
80104304:	e8 4b c2 ff ff       	call   80100554 <panic>
}
80104309:	c9                   	leave  
8010430a:	c3                   	ret    

8010430b <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010430b:	55                   	push   %ebp
8010430c:	89 e5                	mov    %esp,%ebp
8010430e:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104311:	e8 70 0d 00 00       	call   80105086 <pushcli>
  c = mycpu();
80104316:	e8 6c ff ff ff       	call   80104287 <mycpu>
8010431b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
8010431e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104321:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104327:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010432a:	e8 a1 0d 00 00       	call   801050d0 <popcli>
  return p;
8010432f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104332:	c9                   	leave  
80104333:	c3                   	ret    

80104334 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104334:	55                   	push   %ebp
80104335:	89 e5                	mov    %esp,%ebp
80104337:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010433a:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104341:	e8 e1 0b 00 00       	call   80104f27 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104346:	c7 45 f4 14 52 11 80 	movl   $0x80115214,-0xc(%ebp)
8010434d:	eb 50                	jmp    8010439f <allocproc+0x6b>
    if(p->state == UNUSED)
8010434f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104352:	8b 40 0c             	mov    0xc(%eax),%eax
80104355:	85 c0                	test   %eax,%eax
80104357:	75 42                	jne    8010439b <allocproc+0x67>
      goto found;
80104359:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010435a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435d:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104364:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104369:	8d 50 01             	lea    0x1(%eax),%edx
8010436c:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104372:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104375:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80104378:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
8010437f:	e8 0d 0c 00 00       	call   80104f91 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104384:	e8 c2 e9 ff ff       	call   80102d4b <kalloc>
80104389:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010438c:	89 42 08             	mov    %eax,0x8(%edx)
8010438f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104392:	8b 40 08             	mov    0x8(%eax),%eax
80104395:	85 c0                	test   %eax,%eax
80104397:	75 36                	jne    801043cf <allocproc+0x9b>
80104399:	eb 23                	jmp    801043be <allocproc+0x8a>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010439b:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010439f:	81 7d f4 14 72 11 80 	cmpl   $0x80117214,-0xc(%ebp)
801043a6:	72 a7                	jb     8010434f <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801043a8:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
801043af:	e8 dd 0b 00 00       	call   80104f91 <release>
  return 0;
801043b4:	b8 00 00 00 00       	mov    $0x0,%eax
801043b9:	e9 80 00 00 00       	jmp    8010443e <allocproc+0x10a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043c8:	b8 00 00 00 00       	mov    $0x0,%eax
801043cd:	eb 6f                	jmp    8010443e <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d2:	8b 40 08             	mov    0x8(%eax),%eax
801043d5:	05 00 10 00 00       	add    $0x1000,%eax
801043da:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043dd:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043e7:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043ea:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043ee:	ba 40 68 10 80       	mov    $0x80106840,%edx
801043f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043f6:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043f8:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801043fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104402:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104408:	8b 40 1c             	mov    0x1c(%eax),%eax
8010440b:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104412:	00 
80104413:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010441a:	00 
8010441b:	89 04 24             	mov    %eax,(%esp)
8010441e:	e8 67 0d 00 00       	call   8010518a <memset>
  p->context->eip = (uint)forkret;
80104423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104426:	8b 40 1c             	mov    0x1c(%eax),%eax
80104429:	ba 1a 4b 10 80       	mov    $0x80104b1a,%edx
8010442e:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
80104431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104434:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)

  return p;
8010443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010443e:	c9                   	leave  
8010443f:	c3                   	ret    

80104440 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104440:	55                   	push   %ebp
80104441:	89 e5                	mov    %esp,%ebp
80104443:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104446:	e8 e9 fe ff ff       	call   80104334 <allocproc>
8010444b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010444e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104451:	a3 c0 c8 10 80       	mov    %eax,0x8010c8c0
  if((p->pgdir = setupkvm()) == 0)
80104456:	e8 3f 39 00 00       	call   80107d9a <setupkvm>
8010445b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010445e:	89 42 04             	mov    %eax,0x4(%edx)
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	8b 40 04             	mov    0x4(%eax),%eax
80104467:	85 c0                	test   %eax,%eax
80104469:	75 0c                	jne    80104477 <userinit+0x37>
    panic("userinit: out of memory?");
8010446b:	c7 04 24 72 8e 10 80 	movl   $0x80108e72,(%esp)
80104472:	e8 dd c0 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104477:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010447c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447f:	8b 40 04             	mov    0x4(%eax),%eax
80104482:	89 54 24 08          	mov    %edx,0x8(%esp)
80104486:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
8010448d:	80 
8010448e:	89 04 24             	mov    %eax,(%esp)
80104491:	e8 65 3b 00 00       	call   80107ffb <inituvm>
  p->sz = PGSIZE;
80104496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104499:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010449f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a2:	8b 40 18             	mov    0x18(%eax),%eax
801044a5:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044ac:	00 
801044ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044b4:	00 
801044b5:	89 04 24             	mov    %eax,(%esp)
801044b8:	e8 cd 0c 00 00       	call   8010518a <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c0:	8b 40 18             	mov    0x18(%eax),%eax
801044c3:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cc:	8b 40 18             	mov    0x18(%eax),%eax
801044cf:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d8:	8b 50 18             	mov    0x18(%eax),%edx
801044db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044de:	8b 40 18             	mov    0x18(%eax),%eax
801044e1:	8b 40 2c             	mov    0x2c(%eax),%eax
801044e4:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
801044e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044eb:	8b 50 18             	mov    0x18(%eax),%edx
801044ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f1:	8b 40 18             	mov    0x18(%eax),%eax
801044f4:	8b 40 2c             	mov    0x2c(%eax),%eax
801044f7:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
801044fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fe:	8b 40 18             	mov    0x18(%eax),%eax
80104501:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450b:	8b 40 18             	mov    0x18(%eax),%eax
8010450e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	8b 40 18             	mov    0x18(%eax),%eax
8010451b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104525:	83 c0 6c             	add    $0x6c,%eax
80104528:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010452f:	00 
80104530:	c7 44 24 04 8b 8e 10 	movl   $0x80108e8b,0x4(%esp)
80104537:	80 
80104538:	89 04 24             	mov    %eax,(%esp)
8010453b:	e8 56 0e 00 00       	call   80105396 <safestrcpy>
  p->cwd = namei("/");
80104540:	c7 04 24 94 8e 10 80 	movl   $0x80108e94,(%esp)
80104547:	e8 f3 e0 ff ff       	call   8010263f <namei>
8010454c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010454f:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104552:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104559:	e8 c9 09 00 00       	call   80104f27 <acquire>

  p->state = RUNNABLE;
8010455e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104561:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104568:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
8010456f:	e8 1d 0a 00 00       	call   80104f91 <release>
}
80104574:	c9                   	leave  
80104575:	c3                   	ret    

80104576 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104576:	55                   	push   %ebp
80104577:	89 e5                	mov    %esp,%ebp
80104579:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
8010457c:	e8 8a fd ff ff       	call   8010430b <myproc>
80104581:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104587:	8b 00                	mov    (%eax),%eax
80104589:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010458c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104590:	7e 31                	jle    801045c3 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104592:	8b 55 08             	mov    0x8(%ebp),%edx
80104595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104598:	01 c2                	add    %eax,%edx
8010459a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010459d:	8b 40 04             	mov    0x4(%eax),%eax
801045a0:	89 54 24 08          	mov    %edx,0x8(%esp)
801045a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801045ab:	89 04 24             	mov    %eax,(%esp)
801045ae:	e8 b3 3b 00 00       	call   80108166 <allocuvm>
801045b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045ba:	75 3e                	jne    801045fa <growproc+0x84>
      return -1;
801045bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c1:	eb 4f                	jmp    80104612 <growproc+0x9c>
  } else if(n < 0){
801045c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045c7:	79 31                	jns    801045fa <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045c9:	8b 55 08             	mov    0x8(%ebp),%edx
801045cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cf:	01 c2                	add    %eax,%edx
801045d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045d4:	8b 40 04             	mov    0x4(%eax),%eax
801045d7:	89 54 24 08          	mov    %edx,0x8(%esp)
801045db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045de:	89 54 24 04          	mov    %edx,0x4(%esp)
801045e2:	89 04 24             	mov    %eax,(%esp)
801045e5:	e8 92 3c 00 00       	call   8010827c <deallocuvm>
801045ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045f1:	75 07                	jne    801045fa <growproc+0x84>
      return -1;
801045f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045f8:	eb 18                	jmp    80104612 <growproc+0x9c>
  }
  curproc->sz = sz;
801045fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104600:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104605:	89 04 24             	mov    %eax,(%esp)
80104608:	e8 67 38 00 00       	call   80107e74 <switchuvm>
  return 0;
8010460d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104612:	c9                   	leave  
80104613:	c3                   	ret    

80104614 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104614:	55                   	push   %ebp
80104615:	89 e5                	mov    %esp,%ebp
80104617:	57                   	push   %edi
80104618:	56                   	push   %esi
80104619:	53                   	push   %ebx
8010461a:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010461d:	e8 e9 fc ff ff       	call   8010430b <myproc>
80104622:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104625:	e8 0a fd ff ff       	call   80104334 <allocproc>
8010462a:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010462d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104631:	75 0a                	jne    8010463d <fork+0x29>
    return -1;
80104633:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104638:	e9 35 01 00 00       	jmp    80104772 <fork+0x15e>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010463d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104640:	8b 10                	mov    (%eax),%edx
80104642:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104645:	8b 40 04             	mov    0x4(%eax),%eax
80104648:	89 54 24 04          	mov    %edx,0x4(%esp)
8010464c:	89 04 24             	mov    %eax,(%esp)
8010464f:	e8 c8 3d 00 00       	call   8010841c <copyuvm>
80104654:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104657:	89 42 04             	mov    %eax,0x4(%edx)
8010465a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010465d:	8b 40 04             	mov    0x4(%eax),%eax
80104660:	85 c0                	test   %eax,%eax
80104662:	75 2c                	jne    80104690 <fork+0x7c>
    kfree(np->kstack);
80104664:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104667:	8b 40 08             	mov    0x8(%eax),%eax
8010466a:	89 04 24             	mov    %eax,(%esp)
8010466d:	e8 43 e6 ff ff       	call   80102cb5 <kfree>
    np->kstack = 0;
80104672:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104675:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010467c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010467f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010468b:	e9 e2 00 00 00       	jmp    80104772 <fork+0x15e>
  }
  np->sz = curproc->sz;
80104690:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104693:	8b 10                	mov    (%eax),%edx
80104695:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104698:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010469a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010469d:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046a0:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801046a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046a6:	8b 50 18             	mov    0x18(%eax),%edx
801046a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ac:	8b 40 18             	mov    0x18(%eax),%eax
801046af:	89 c3                	mov    %eax,%ebx
801046b1:	b8 13 00 00 00       	mov    $0x13,%eax
801046b6:	89 d7                	mov    %edx,%edi
801046b8:	89 de                	mov    %ebx,%esi
801046ba:	89 c1                	mov    %eax,%ecx
801046bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046c1:	8b 40 18             	mov    0x18(%eax),%eax
801046c4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046cb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046d2:	eb 36                	jmp    8010470a <fork+0xf6>
    if(curproc->ofile[i])
801046d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046da:	83 c2 08             	add    $0x8,%edx
801046dd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046e1:	85 c0                	test   %eax,%eax
801046e3:	74 22                	je     80104707 <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
801046e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046eb:	83 c2 08             	add    $0x8,%edx
801046ee:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046f2:	89 04 24             	mov    %eax,(%esp)
801046f5:	e8 50 ca ff ff       	call   8010114a <filedup>
801046fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046fd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104700:	83 c1 08             	add    $0x8,%ecx
80104703:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104707:	ff 45 e4             	incl   -0x1c(%ebp)
8010470a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010470e:	7e c4                	jle    801046d4 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104710:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104713:	8b 40 68             	mov    0x68(%eax),%eax
80104716:	89 04 24             	mov    %eax,(%esp)
80104719:	e8 ca d3 ff ff       	call   80101ae8 <idup>
8010471e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104721:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104724:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104727:	8d 50 6c             	lea    0x6c(%eax),%edx
8010472a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010472d:	83 c0 6c             	add    $0x6c,%eax
80104730:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104737:	00 
80104738:	89 54 24 04          	mov    %edx,0x4(%esp)
8010473c:	89 04 24             	mov    %eax,(%esp)
8010473f:	e8 52 0c 00 00       	call   80105396 <safestrcpy>

  pid = np->pid;
80104744:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104747:	8b 40 10             	mov    0x10(%eax),%eax
8010474a:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010474d:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104754:	e8 ce 07 00 00       	call   80104f27 <acquire>

  np->state = RUNNABLE;
80104759:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010475c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104763:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
8010476a:	e8 22 08 00 00       	call   80104f91 <release>

  return pid;
8010476f:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104772:	83 c4 2c             	add    $0x2c,%esp
80104775:	5b                   	pop    %ebx
80104776:	5e                   	pop    %esi
80104777:	5f                   	pop    %edi
80104778:	5d                   	pop    %ebp
80104779:	c3                   	ret    

8010477a <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010477a:	55                   	push   %ebp
8010477b:	89 e5                	mov    %esp,%ebp
8010477d:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
80104780:	e8 86 fb ff ff       	call   8010430b <myproc>
80104785:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104788:	a1 c0 c8 10 80       	mov    0x8010c8c0,%eax
8010478d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104790:	75 0c                	jne    8010479e <exit+0x24>
    panic("init exiting");
80104792:	c7 04 24 96 8e 10 80 	movl   $0x80108e96,(%esp)
80104799:	e8 b6 bd ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010479e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047a5:	eb 3a                	jmp    801047e1 <exit+0x67>
    if(curproc->ofile[fd]){
801047a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047ad:	83 c2 08             	add    $0x8,%edx
801047b0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047b4:	85 c0                	test   %eax,%eax
801047b6:	74 26                	je     801047de <exit+0x64>
      fileclose(curproc->ofile[fd]);
801047b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047be:	83 c2 08             	add    $0x8,%edx
801047c1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047c5:	89 04 24             	mov    %eax,(%esp)
801047c8:	e8 c5 c9 ff ff       	call   80101192 <fileclose>
      curproc->ofile[fd] = 0;
801047cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047d3:	83 c2 08             	add    $0x8,%edx
801047d6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801047dd:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047de:	ff 45 f0             	incl   -0x10(%ebp)
801047e1:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801047e5:	7e c0                	jle    801047a7 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
801047e7:	e8 27 ee ff ff       	call   80103613 <begin_op>
  iput(curproc->cwd);
801047ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047ef:	8b 40 68             	mov    0x68(%eax),%eax
801047f2:	89 04 24             	mov    %eax,(%esp)
801047f5:	e8 6e d4 ff ff       	call   80101c68 <iput>
  end_op();
801047fa:	e8 96 ee ff ff       	call   80103695 <end_op>
  curproc->cwd = 0;
801047ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104802:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104809:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104810:	e8 12 07 00 00       	call   80104f27 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104815:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104818:	8b 40 14             	mov    0x14(%eax),%eax
8010481b:	89 04 24             	mov    %eax,(%esp)
8010481e:	e8 cc 03 00 00       	call   80104bef <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104823:	c7 45 f4 14 52 11 80 	movl   $0x80115214,-0xc(%ebp)
8010482a:	eb 33                	jmp    8010485f <exit+0xe5>
    if(p->parent == curproc){
8010482c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482f:	8b 40 14             	mov    0x14(%eax),%eax
80104832:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104835:	75 24                	jne    8010485b <exit+0xe1>
      p->parent = initproc;
80104837:	8b 15 c0 c8 10 80    	mov    0x8010c8c0,%edx
8010483d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104840:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104846:	8b 40 0c             	mov    0xc(%eax),%eax
80104849:	83 f8 05             	cmp    $0x5,%eax
8010484c:	75 0d                	jne    8010485b <exit+0xe1>
        wakeup1(initproc);
8010484e:	a1 c0 c8 10 80       	mov    0x8010c8c0,%eax
80104853:	89 04 24             	mov    %eax,(%esp)
80104856:	e8 94 03 00 00       	call   80104bef <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010485b:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010485f:	81 7d f4 14 72 11 80 	cmpl   $0x80117214,-0xc(%ebp)
80104866:	72 c4                	jb     8010482c <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104868:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010486b:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104872:	e8 c3 01 00 00       	call   80104a3a <sched>
  panic("zombie exit");
80104877:	c7 04 24 a3 8e 10 80 	movl   $0x80108ea3,(%esp)
8010487e:	e8 d1 bc ff ff       	call   80100554 <panic>

80104883 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104883:	55                   	push   %ebp
80104884:	89 e5                	mov    %esp,%ebp
80104886:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104889:	e8 7d fa ff ff       	call   8010430b <myproc>
8010488e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104891:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104898:	e8 8a 06 00 00       	call   80104f27 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010489d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a4:	c7 45 f4 14 52 11 80 	movl   $0x80115214,-0xc(%ebp)
801048ab:	e9 95 00 00 00       	jmp    80104945 <wait+0xc2>
      if(p->parent != curproc)
801048b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b3:	8b 40 14             	mov    0x14(%eax),%eax
801048b6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801048b9:	74 05                	je     801048c0 <wait+0x3d>
        continue;
801048bb:	e9 81 00 00 00       	jmp    80104941 <wait+0xbe>
      havekids = 1;
801048c0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801048c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ca:	8b 40 0c             	mov    0xc(%eax),%eax
801048cd:	83 f8 05             	cmp    $0x5,%eax
801048d0:	75 6f                	jne    80104941 <wait+0xbe>
        // Found one.
        pid = p->pid;
801048d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d5:	8b 40 10             	mov    0x10(%eax),%eax
801048d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801048db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048de:	8b 40 08             	mov    0x8(%eax),%eax
801048e1:	89 04 24             	mov    %eax,(%esp)
801048e4:	e8 cc e3 ff ff       	call   80102cb5 <kfree>
        p->kstack = 0;
801048e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801048f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f6:	8b 40 04             	mov    0x4(%eax),%eax
801048f9:	89 04 24             	mov    %eax,(%esp)
801048fc:	e8 3f 3a 00 00       	call   80108340 <freevm>
        p->pid = 0;
80104901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104904:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010490b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104918:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010491c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104929:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104930:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104937:	e8 55 06 00 00       	call   80104f91 <release>
        return pid;
8010493c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010493f:	eb 4c                	jmp    8010498d <wait+0x10a>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104941:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104945:	81 7d f4 14 72 11 80 	cmpl   $0x80117214,-0xc(%ebp)
8010494c:	0f 82 5e ff ff ff    	jb     801048b0 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104952:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104956:	74 0a                	je     80104962 <wait+0xdf>
80104958:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010495b:	8b 40 24             	mov    0x24(%eax),%eax
8010495e:	85 c0                	test   %eax,%eax
80104960:	74 13                	je     80104975 <wait+0xf2>
      release(&ptable.lock);
80104962:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104969:	e8 23 06 00 00       	call   80104f91 <release>
      return -1;
8010496e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104973:	eb 18                	jmp    8010498d <wait+0x10a>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104975:	c7 44 24 04 e0 51 11 	movl   $0x801151e0,0x4(%esp)
8010497c:	80 
8010497d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104980:	89 04 24             	mov    %eax,(%esp)
80104983:	e8 d1 01 00 00       	call   80104b59 <sleep>
  }
80104988:	e9 10 ff ff ff       	jmp    8010489d <wait+0x1a>
}
8010498d:	c9                   	leave  
8010498e:	c3                   	ret    

8010498f <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010498f:	55                   	push   %ebp
80104990:	89 e5                	mov    %esp,%ebp
80104992:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104995:	e8 ed f8 ff ff       	call   80104287 <mycpu>
8010499a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
8010499d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049a0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801049a7:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801049aa:	e8 71 f8 ff ff       	call   80104220 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801049af:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
801049b6:	e8 6c 05 00 00       	call   80104f27 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049bb:	c7 45 f4 14 52 11 80 	movl   $0x80115214,-0xc(%ebp)
801049c2:	eb 5c                	jmp    80104a20 <scheduler+0x91>
      if(p->state != RUNNABLE)
801049c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c7:	8b 40 0c             	mov    0xc(%eax),%eax
801049ca:	83 f8 03             	cmp    $0x3,%eax
801049cd:	74 02                	je     801049d1 <scheduler+0x42>
        continue;
801049cf:	eb 4b                	jmp    80104a1c <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801049d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049d7:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801049dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e0:	89 04 24             	mov    %eax,(%esp)
801049e3:	e8 8c 34 00 00       	call   80107e74 <switchuvm>
      p->state = RUNNING;
801049e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049eb:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801049f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f5:	8b 40 1c             	mov    0x1c(%eax),%eax
801049f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049fb:	83 c2 04             	add    $0x4,%edx
801049fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a02:	89 14 24             	mov    %edx,(%esp)
80104a05:	e8 fa 09 00 00       	call   80105404 <swtch>
      switchkvm();
80104a0a:	e8 4b 34 00 00       	call   80107e5a <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a12:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a19:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a1c:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104a20:	81 7d f4 14 72 11 80 	cmpl   $0x80117214,-0xc(%ebp)
80104a27:	72 9b                	jb     801049c4 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104a29:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104a30:	e8 5c 05 00 00       	call   80104f91 <release>

  }
80104a35:	e9 70 ff ff ff       	jmp    801049aa <scheduler+0x1b>

80104a3a <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104a3a:	55                   	push   %ebp
80104a3b:	89 e5                	mov    %esp,%ebp
80104a3d:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104a40:	e8 c6 f8 ff ff       	call   8010430b <myproc>
80104a45:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104a48:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104a4f:	e8 01 06 00 00       	call   80105055 <holding>
80104a54:	85 c0                	test   %eax,%eax
80104a56:	75 0c                	jne    80104a64 <sched+0x2a>
    panic("sched ptable.lock");
80104a58:	c7 04 24 af 8e 10 80 	movl   $0x80108eaf,(%esp)
80104a5f:	e8 f0 ba ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104a64:	e8 1e f8 ff ff       	call   80104287 <mycpu>
80104a69:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a6f:	83 f8 01             	cmp    $0x1,%eax
80104a72:	74 0c                	je     80104a80 <sched+0x46>
    panic("sched locks");
80104a74:	c7 04 24 c1 8e 10 80 	movl   $0x80108ec1,(%esp)
80104a7b:	e8 d4 ba ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a83:	8b 40 0c             	mov    0xc(%eax),%eax
80104a86:	83 f8 04             	cmp    $0x4,%eax
80104a89:	75 0c                	jne    80104a97 <sched+0x5d>
    panic("sched running");
80104a8b:	c7 04 24 cd 8e 10 80 	movl   $0x80108ecd,(%esp)
80104a92:	e8 bd ba ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104a97:	e8 74 f7 ff ff       	call   80104210 <readeflags>
80104a9c:	25 00 02 00 00       	and    $0x200,%eax
80104aa1:	85 c0                	test   %eax,%eax
80104aa3:	74 0c                	je     80104ab1 <sched+0x77>
    panic("sched interruptible");
80104aa5:	c7 04 24 db 8e 10 80 	movl   $0x80108edb,(%esp)
80104aac:	e8 a3 ba ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104ab1:	e8 d1 f7 ff ff       	call   80104287 <mycpu>
80104ab6:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104abc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104abf:	e8 c3 f7 ff ff       	call   80104287 <mycpu>
80104ac4:	8b 40 04             	mov    0x4(%eax),%eax
80104ac7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104aca:	83 c2 1c             	add    $0x1c,%edx
80104acd:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ad1:	89 14 24             	mov    %edx,(%esp)
80104ad4:	e8 2b 09 00 00       	call   80105404 <swtch>
  mycpu()->intena = intena;
80104ad9:	e8 a9 f7 ff ff       	call   80104287 <mycpu>
80104ade:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ae1:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104ae7:	c9                   	leave  
80104ae8:	c3                   	ret    

80104ae9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104ae9:	55                   	push   %ebp
80104aea:	89 e5                	mov    %esp,%ebp
80104aec:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104aef:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104af6:	e8 2c 04 00 00       	call   80104f27 <acquire>
  myproc()->state = RUNNABLE;
80104afb:	e8 0b f8 ff ff       	call   8010430b <myproc>
80104b00:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b07:	e8 2e ff ff ff       	call   80104a3a <sched>
  release(&ptable.lock);
80104b0c:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104b13:	e8 79 04 00 00       	call   80104f91 <release>
}
80104b18:	c9                   	leave  
80104b19:	c3                   	ret    

80104b1a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b1a:	55                   	push   %ebp
80104b1b:	89 e5                	mov    %esp,%ebp
80104b1d:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b20:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104b27:	e8 65 04 00 00       	call   80104f91 <release>

  if (first) {
80104b2c:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104b31:	85 c0                	test   %eax,%eax
80104b33:	74 22                	je     80104b57 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104b35:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104b3c:	00 00 00 
    iinit(ROOTDEV);
80104b3f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104b46:	e8 68 cc ff ff       	call   801017b3 <iinit>
    initlog(ROOTDEV);
80104b4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104b52:	e8 bd e8 ff ff       	call   80103414 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104b57:	c9                   	leave  
80104b58:	c3                   	ret    

80104b59 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104b59:	55                   	push   %ebp
80104b5a:	89 e5                	mov    %esp,%ebp
80104b5c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104b5f:	e8 a7 f7 ff ff       	call   8010430b <myproc>
80104b64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104b67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104b6b:	75 0c                	jne    80104b79 <sleep+0x20>
    panic("sleep");
80104b6d:	c7 04 24 ef 8e 10 80 	movl   $0x80108eef,(%esp)
80104b74:	e8 db b9 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104b79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b7d:	75 0c                	jne    80104b8b <sleep+0x32>
    panic("sleep without lk");
80104b7f:	c7 04 24 f5 8e 10 80 	movl   $0x80108ef5,(%esp)
80104b86:	e8 c9 b9 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104b8b:	81 7d 0c e0 51 11 80 	cmpl   $0x801151e0,0xc(%ebp)
80104b92:	74 17                	je     80104bab <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104b94:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104b9b:	e8 87 03 00 00       	call   80104f27 <acquire>
    release(lk);
80104ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba3:	89 04 24             	mov    %eax,(%esp)
80104ba6:	e8 e6 03 00 00       	call   80104f91 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bae:	8b 55 08             	mov    0x8(%ebp),%edx
80104bb1:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104bbe:	e8 77 fe ff ff       	call   80104a3a <sched>

  // Tidy up.
  p->chan = 0;
80104bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc6:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104bcd:	81 7d 0c e0 51 11 80 	cmpl   $0x801151e0,0xc(%ebp)
80104bd4:	74 17                	je     80104bed <sleep+0x94>
    release(&ptable.lock);
80104bd6:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104bdd:	e8 af 03 00 00       	call   80104f91 <release>
    acquire(lk);
80104be2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104be5:	89 04 24             	mov    %eax,(%esp)
80104be8:	e8 3a 03 00 00       	call   80104f27 <acquire>
  }
}
80104bed:	c9                   	leave  
80104bee:	c3                   	ret    

80104bef <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104bef:	55                   	push   %ebp
80104bf0:	89 e5                	mov    %esp,%ebp
80104bf2:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104bf5:	c7 45 fc 14 52 11 80 	movl   $0x80115214,-0x4(%ebp)
80104bfc:	eb 24                	jmp    80104c22 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104bfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c01:	8b 40 0c             	mov    0xc(%eax),%eax
80104c04:	83 f8 02             	cmp    $0x2,%eax
80104c07:	75 15                	jne    80104c1e <wakeup1+0x2f>
80104c09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c0c:	8b 40 20             	mov    0x20(%eax),%eax
80104c0f:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c12:	75 0a                	jne    80104c1e <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c17:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c1e:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104c22:	81 7d fc 14 72 11 80 	cmpl   $0x80117214,-0x4(%ebp)
80104c29:	72 d3                	jb     80104bfe <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c2b:	c9                   	leave  
80104c2c:	c3                   	ret    

80104c2d <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c2d:	55                   	push   %ebp
80104c2e:	89 e5                	mov    %esp,%ebp
80104c30:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104c33:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104c3a:	e8 e8 02 00 00       	call   80104f27 <acquire>
  wakeup1(chan);
80104c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c42:	89 04 24             	mov    %eax,(%esp)
80104c45:	e8 a5 ff ff ff       	call   80104bef <wakeup1>
  release(&ptable.lock);
80104c4a:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104c51:	e8 3b 03 00 00       	call   80104f91 <release>
}
80104c56:	c9                   	leave  
80104c57:	c3                   	ret    

80104c58 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104c58:	55                   	push   %ebp
80104c59:	89 e5                	mov    %esp,%ebp
80104c5b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104c5e:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104c65:	e8 bd 02 00 00       	call   80104f27 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c6a:	c7 45 f4 14 52 11 80 	movl   $0x80115214,-0xc(%ebp)
80104c71:	eb 41                	jmp    80104cb4 <kill+0x5c>
    if(p->pid == pid){
80104c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c76:	8b 40 10             	mov    0x10(%eax),%eax
80104c79:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c7c:	75 32                	jne    80104cb0 <kill+0x58>
      p->killed = 1;
80104c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c81:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c8e:	83 f8 02             	cmp    $0x2,%eax
80104c91:	75 0a                	jne    80104c9d <kill+0x45>
        p->state = RUNNABLE;
80104c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c96:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104c9d:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104ca4:	e8 e8 02 00 00       	call   80104f91 <release>
      return 0;
80104ca9:	b8 00 00 00 00       	mov    $0x0,%eax
80104cae:	eb 1e                	jmp    80104cce <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cb0:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104cb4:	81 7d f4 14 72 11 80 	cmpl   $0x80117214,-0xc(%ebp)
80104cbb:	72 b6                	jb     80104c73 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104cbd:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80104cc4:	e8 c8 02 00 00       	call   80104f91 <release>
  return -1;
80104cc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cce:	c9                   	leave  
80104ccf:	c3                   	ret    

80104cd0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104cd0:	55                   	push   %ebp
80104cd1:	89 e5                	mov    %esp,%ebp
80104cd3:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cd6:	c7 45 f0 14 52 11 80 	movl   $0x80115214,-0x10(%ebp)
80104cdd:	e9 d5 00 00 00       	jmp    80104db7 <procdump+0xe7>
    if(p->state == UNUSED)
80104ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ce5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ce8:	85 c0                	test   %eax,%eax
80104cea:	75 05                	jne    80104cf1 <procdump+0x21>
      continue;
80104cec:	e9 c2 00 00 00       	jmp    80104db3 <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cf4:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf7:	83 f8 05             	cmp    $0x5,%eax
80104cfa:	77 23                	ja     80104d1f <procdump+0x4f>
80104cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cff:	8b 40 0c             	mov    0xc(%eax),%eax
80104d02:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d09:	85 c0                	test   %eax,%eax
80104d0b:	74 12                	je     80104d1f <procdump+0x4f>
      state = states[p->state];
80104d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d10:	8b 40 0c             	mov    0xc(%eax),%eax
80104d13:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d1d:	eb 07                	jmp    80104d26 <procdump+0x56>
    else
      state = "???";
80104d1f:	c7 45 ec 06 8f 10 80 	movl   $0x80108f06,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d29:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d2f:	8b 40 10             	mov    0x10(%eax),%eax
80104d32:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104d36:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d39:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d41:	c7 04 24 0a 8f 10 80 	movl   $0x80108f0a,(%esp)
80104d48:	e8 74 b6 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d50:	8b 40 0c             	mov    0xc(%eax),%eax
80104d53:	83 f8 02             	cmp    $0x2,%eax
80104d56:	75 4f                	jne    80104da7 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d5b:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d5e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d61:	83 c0 08             	add    $0x8,%eax
80104d64:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104d67:	89 54 24 04          	mov    %edx,0x4(%esp)
80104d6b:	89 04 24             	mov    %eax,(%esp)
80104d6e:	e8 6b 02 00 00       	call   80104fde <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104d73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d7a:	eb 1a                	jmp    80104d96 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104d83:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d87:	c7 04 24 13 8f 10 80 	movl   $0x80108f13,(%esp)
80104d8e:	e8 2e b6 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104d93:	ff 45 f4             	incl   -0xc(%ebp)
80104d96:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104d9a:	7f 0b                	jg     80104da7 <procdump+0xd7>
80104d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104da3:	85 c0                	test   %eax,%eax
80104da5:	75 d5                	jne    80104d7c <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104da7:	c7 04 24 17 8f 10 80 	movl   $0x80108f17,(%esp)
80104dae:	e8 0e b6 ff ff       	call   801003c1 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104db3:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104db7:	81 7d f0 14 72 11 80 	cmpl   $0x80117214,-0x10(%ebp)
80104dbe:	0f 82 1e ff ff ff    	jb     80104ce2 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104dc4:	c9                   	leave  
80104dc5:	c3                   	ret    
	...

80104dc8 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80104dce:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd1:	83 c0 04             	add    $0x4,%eax
80104dd4:	c7 44 24 04 43 8f 10 	movl   $0x80108f43,0x4(%esp)
80104ddb:	80 
80104ddc:	89 04 24             	mov    %eax,(%esp)
80104ddf:	e8 22 01 00 00       	call   80104f06 <initlock>
  lk->name = name;
80104de4:	8b 45 08             	mov    0x8(%ebp),%eax
80104de7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104dea:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104ded:	8b 45 08             	mov    0x8(%ebp),%eax
80104df0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104df6:	8b 45 08             	mov    0x8(%ebp),%eax
80104df9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104e00:	c9                   	leave  
80104e01:	c3                   	ret    

80104e02 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104e02:	55                   	push   %ebp
80104e03:	89 e5                	mov    %esp,%ebp
80104e05:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104e08:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0b:	83 c0 04             	add    $0x4,%eax
80104e0e:	89 04 24             	mov    %eax,(%esp)
80104e11:	e8 11 01 00 00       	call   80104f27 <acquire>
  while (lk->locked) {
80104e16:	eb 15                	jmp    80104e2d <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80104e18:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1b:	83 c0 04             	add    $0x4,%eax
80104e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e22:	8b 45 08             	mov    0x8(%ebp),%eax
80104e25:	89 04 24             	mov    %eax,(%esp)
80104e28:	e8 2c fd ff ff       	call   80104b59 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80104e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e30:	8b 00                	mov    (%eax),%eax
80104e32:	85 c0                	test   %eax,%eax
80104e34:	75 e2                	jne    80104e18 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80104e36:	8b 45 08             	mov    0x8(%ebp),%eax
80104e39:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104e3f:	e8 c7 f4 ff ff       	call   8010430b <myproc>
80104e44:	8b 50 10             	mov    0x10(%eax),%edx
80104e47:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4a:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e50:	83 c0 04             	add    $0x4,%eax
80104e53:	89 04 24             	mov    %eax,(%esp)
80104e56:	e8 36 01 00 00       	call   80104f91 <release>
}
80104e5b:	c9                   	leave  
80104e5c:	c3                   	ret    

80104e5d <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104e5d:	55                   	push   %ebp
80104e5e:	89 e5                	mov    %esp,%ebp
80104e60:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80104e63:	8b 45 08             	mov    0x8(%ebp),%eax
80104e66:	83 c0 04             	add    $0x4,%eax
80104e69:	89 04 24             	mov    %eax,(%esp)
80104e6c:	e8 b6 00 00 00       	call   80104f27 <acquire>
  lk->locked = 0;
80104e71:	8b 45 08             	mov    0x8(%ebp),%eax
80104e74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104e84:	8b 45 08             	mov    0x8(%ebp),%eax
80104e87:	89 04 24             	mov    %eax,(%esp)
80104e8a:	e8 9e fd ff ff       	call   80104c2d <wakeup>
  release(&lk->lk);
80104e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e92:	83 c0 04             	add    $0x4,%eax
80104e95:	89 04 24             	mov    %eax,(%esp)
80104e98:	e8 f4 00 00 00       	call   80104f91 <release>
}
80104e9d:	c9                   	leave  
80104e9e:	c3                   	ret    

80104e9f <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104e9f:	55                   	push   %ebp
80104ea0:	89 e5                	mov    %esp,%ebp
80104ea2:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80104ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea8:	83 c0 04             	add    $0x4,%eax
80104eab:	89 04 24             	mov    %eax,(%esp)
80104eae:	e8 74 00 00 00       	call   80104f27 <acquire>
  r = lk->locked;
80104eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb6:	8b 00                	mov    (%eax),%eax
80104eb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebe:	83 c0 04             	add    $0x4,%eax
80104ec1:	89 04 24             	mov    %eax,(%esp)
80104ec4:	e8 c8 00 00 00       	call   80104f91 <release>
  return r;
80104ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104ecc:	c9                   	leave  
80104ecd:	c3                   	ret    
	...

80104ed0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104ed0:	55                   	push   %ebp
80104ed1:	89 e5                	mov    %esp,%ebp
80104ed3:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ed6:	9c                   	pushf  
80104ed7:	58                   	pop    %eax
80104ed8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104edb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ede:	c9                   	leave  
80104edf:	c3                   	ret    

80104ee0 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104ee0:	55                   	push   %ebp
80104ee1:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ee3:	fa                   	cli    
}
80104ee4:	5d                   	pop    %ebp
80104ee5:	c3                   	ret    

80104ee6 <sti>:

static inline void
sti(void)
{
80104ee6:	55                   	push   %ebp
80104ee7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ee9:	fb                   	sti    
}
80104eea:	5d                   	pop    %ebp
80104eeb:	c3                   	ret    

80104eec <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104eec:	55                   	push   %ebp
80104eed:	89 e5                	mov    %esp,%ebp
80104eef:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104ef2:	8b 55 08             	mov    0x8(%ebp),%edx
80104ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ef8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104efb:	f0 87 02             	lock xchg %eax,(%edx)
80104efe:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104f01:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f04:	c9                   	leave  
80104f05:	c3                   	ret    

80104f06 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104f06:	55                   	push   %ebp
80104f07:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104f09:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f0f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104f12:	8b 45 08             	mov    0x8(%ebp),%eax
80104f15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104f25:	5d                   	pop    %ebp
80104f26:	c3                   	ret    

80104f27 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104f27:	55                   	push   %ebp
80104f28:	89 e5                	mov    %esp,%ebp
80104f2a:	53                   	push   %ebx
80104f2b:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104f2e:	e8 53 01 00 00       	call   80105086 <pushcli>
  if(holding(lk))
80104f33:	8b 45 08             	mov    0x8(%ebp),%eax
80104f36:	89 04 24             	mov    %eax,(%esp)
80104f39:	e8 17 01 00 00       	call   80105055 <holding>
80104f3e:	85 c0                	test   %eax,%eax
80104f40:	74 0c                	je     80104f4e <acquire+0x27>
    panic("acquire");
80104f42:	c7 04 24 4e 8f 10 80 	movl   $0x80108f4e,(%esp)
80104f49:	e8 06 b6 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104f4e:	90                   	nop
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104f59:	00 
80104f5a:	89 04 24             	mov    %eax,(%esp)
80104f5d:	e8 8a ff ff ff       	call   80104eec <xchg>
80104f62:	85 c0                	test   %eax,%eax
80104f64:	75 e9                	jne    80104f4f <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104f66:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104f6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104f6e:	e8 14 f3 ff ff       	call   80104287 <mycpu>
80104f73:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104f76:	8b 45 08             	mov    0x8(%ebp),%eax
80104f79:	83 c0 0c             	add    $0xc,%eax
80104f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f80:	8d 45 08             	lea    0x8(%ebp),%eax
80104f83:	89 04 24             	mov    %eax,(%esp)
80104f86:	e8 53 00 00 00       	call   80104fde <getcallerpcs>
}
80104f8b:	83 c4 14             	add    $0x14,%esp
80104f8e:	5b                   	pop    %ebx
80104f8f:	5d                   	pop    %ebp
80104f90:	c3                   	ret    

80104f91 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104f91:	55                   	push   %ebp
80104f92:	89 e5                	mov    %esp,%ebp
80104f94:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104f97:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9a:	89 04 24             	mov    %eax,(%esp)
80104f9d:	e8 b3 00 00 00       	call   80105055 <holding>
80104fa2:	85 c0                	test   %eax,%eax
80104fa4:	75 0c                	jne    80104fb2 <release+0x21>
    panic("release");
80104fa6:	c7 04 24 56 8f 10 80 	movl   $0x80108f56,(%esp)
80104fad:	e8 a2 b5 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
80104fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104fc6:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80104fce:	8b 55 08             	mov    0x8(%ebp),%edx
80104fd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104fd7:	e8 f4 00 00 00       	call   801050d0 <popcli>
}
80104fdc:	c9                   	leave  
80104fdd:	c3                   	ret    

80104fde <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104fde:	55                   	push   %ebp
80104fdf:	89 e5                	mov    %esp,%ebp
80104fe1:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe7:	83 e8 08             	sub    $0x8,%eax
80104fea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104fed:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104ff4:	eb 37                	jmp    8010502d <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104ff6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104ffa:	74 37                	je     80105033 <getcallerpcs+0x55>
80104ffc:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105003:	76 2e                	jbe    80105033 <getcallerpcs+0x55>
80105005:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105009:	74 28                	je     80105033 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010500b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010500e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105015:	8b 45 0c             	mov    0xc(%ebp),%eax
80105018:	01 c2                	add    %eax,%edx
8010501a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010501d:	8b 40 04             	mov    0x4(%eax),%eax
80105020:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105022:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105025:	8b 00                	mov    (%eax),%eax
80105027:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010502a:	ff 45 f8             	incl   -0x8(%ebp)
8010502d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105031:	7e c3                	jle    80104ff6 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105033:	eb 18                	jmp    8010504d <getcallerpcs+0x6f>
    pcs[i] = 0;
80105035:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105038:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010503f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105042:	01 d0                	add    %edx,%eax
80105044:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010504a:	ff 45 f8             	incl   -0x8(%ebp)
8010504d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105051:	7e e2                	jle    80105035 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80105053:	c9                   	leave  
80105054:	c3                   	ret    

80105055 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105055:	55                   	push   %ebp
80105056:	89 e5                	mov    %esp,%ebp
80105058:	53                   	push   %ebx
80105059:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010505c:	8b 45 08             	mov    0x8(%ebp),%eax
8010505f:	8b 00                	mov    (%eax),%eax
80105061:	85 c0                	test   %eax,%eax
80105063:	74 16                	je     8010507b <holding+0x26>
80105065:	8b 45 08             	mov    0x8(%ebp),%eax
80105068:	8b 58 08             	mov    0x8(%eax),%ebx
8010506b:	e8 17 f2 ff ff       	call   80104287 <mycpu>
80105070:	39 c3                	cmp    %eax,%ebx
80105072:	75 07                	jne    8010507b <holding+0x26>
80105074:	b8 01 00 00 00       	mov    $0x1,%eax
80105079:	eb 05                	jmp    80105080 <holding+0x2b>
8010507b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105080:	83 c4 04             	add    $0x4,%esp
80105083:	5b                   	pop    %ebx
80105084:	5d                   	pop    %ebp
80105085:	c3                   	ret    

80105086 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105086:	55                   	push   %ebp
80105087:	89 e5                	mov    %esp,%ebp
80105089:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010508c:	e8 3f fe ff ff       	call   80104ed0 <readeflags>
80105091:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105094:	e8 47 fe ff ff       	call   80104ee0 <cli>
  if(mycpu()->ncli == 0)
80105099:	e8 e9 f1 ff ff       	call   80104287 <mycpu>
8010509e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801050a4:	85 c0                	test   %eax,%eax
801050a6:	75 14                	jne    801050bc <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801050a8:	e8 da f1 ff ff       	call   80104287 <mycpu>
801050ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050b0:	81 e2 00 02 00 00    	and    $0x200,%edx
801050b6:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801050bc:	e8 c6 f1 ff ff       	call   80104287 <mycpu>
801050c1:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801050c7:	42                   	inc    %edx
801050c8:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801050ce:	c9                   	leave  
801050cf:	c3                   	ret    

801050d0 <popcli>:

void
popcli(void)
{
801050d0:	55                   	push   %ebp
801050d1:	89 e5                	mov    %esp,%ebp
801050d3:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801050d6:	e8 f5 fd ff ff       	call   80104ed0 <readeflags>
801050db:	25 00 02 00 00       	and    $0x200,%eax
801050e0:	85 c0                	test   %eax,%eax
801050e2:	74 0c                	je     801050f0 <popcli+0x20>
    panic("popcli - interruptible");
801050e4:	c7 04 24 5e 8f 10 80 	movl   $0x80108f5e,(%esp)
801050eb:	e8 64 b4 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
801050f0:	e8 92 f1 ff ff       	call   80104287 <mycpu>
801050f5:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801050fb:	4a                   	dec    %edx
801050fc:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105102:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105108:	85 c0                	test   %eax,%eax
8010510a:	79 0c                	jns    80105118 <popcli+0x48>
    panic("popcli");
8010510c:	c7 04 24 75 8f 10 80 	movl   $0x80108f75,(%esp)
80105113:	e8 3c b4 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105118:	e8 6a f1 ff ff       	call   80104287 <mycpu>
8010511d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105123:	85 c0                	test   %eax,%eax
80105125:	75 14                	jne    8010513b <popcli+0x6b>
80105127:	e8 5b f1 ff ff       	call   80104287 <mycpu>
8010512c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105132:	85 c0                	test   %eax,%eax
80105134:	74 05                	je     8010513b <popcli+0x6b>
    sti();
80105136:	e8 ab fd ff ff       	call   80104ee6 <sti>
}
8010513b:	c9                   	leave  
8010513c:	c3                   	ret    
8010513d:	00 00                	add    %al,(%eax)
	...

80105140 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105140:	55                   	push   %ebp
80105141:	89 e5                	mov    %esp,%ebp
80105143:	57                   	push   %edi
80105144:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105145:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105148:	8b 55 10             	mov    0x10(%ebp),%edx
8010514b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010514e:	89 cb                	mov    %ecx,%ebx
80105150:	89 df                	mov    %ebx,%edi
80105152:	89 d1                	mov    %edx,%ecx
80105154:	fc                   	cld    
80105155:	f3 aa                	rep stos %al,%es:(%edi)
80105157:	89 ca                	mov    %ecx,%edx
80105159:	89 fb                	mov    %edi,%ebx
8010515b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010515e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105161:	5b                   	pop    %ebx
80105162:	5f                   	pop    %edi
80105163:	5d                   	pop    %ebp
80105164:	c3                   	ret    

80105165 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105165:	55                   	push   %ebp
80105166:	89 e5                	mov    %esp,%ebp
80105168:	57                   	push   %edi
80105169:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010516a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010516d:	8b 55 10             	mov    0x10(%ebp),%edx
80105170:	8b 45 0c             	mov    0xc(%ebp),%eax
80105173:	89 cb                	mov    %ecx,%ebx
80105175:	89 df                	mov    %ebx,%edi
80105177:	89 d1                	mov    %edx,%ecx
80105179:	fc                   	cld    
8010517a:	f3 ab                	rep stos %eax,%es:(%edi)
8010517c:	89 ca                	mov    %ecx,%edx
8010517e:	89 fb                	mov    %edi,%ebx
80105180:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105183:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105186:	5b                   	pop    %ebx
80105187:	5f                   	pop    %edi
80105188:	5d                   	pop    %ebp
80105189:	c3                   	ret    

8010518a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010518a:	55                   	push   %ebp
8010518b:	89 e5                	mov    %esp,%ebp
8010518d:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105190:	8b 45 08             	mov    0x8(%ebp),%eax
80105193:	83 e0 03             	and    $0x3,%eax
80105196:	85 c0                	test   %eax,%eax
80105198:	75 49                	jne    801051e3 <memset+0x59>
8010519a:	8b 45 10             	mov    0x10(%ebp),%eax
8010519d:	83 e0 03             	and    $0x3,%eax
801051a0:	85 c0                	test   %eax,%eax
801051a2:	75 3f                	jne    801051e3 <memset+0x59>
    c &= 0xFF;
801051a4:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801051ab:	8b 45 10             	mov    0x10(%ebp),%eax
801051ae:	c1 e8 02             	shr    $0x2,%eax
801051b1:	89 c2                	mov    %eax,%edx
801051b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b6:	c1 e0 18             	shl    $0x18,%eax
801051b9:	89 c1                	mov    %eax,%ecx
801051bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801051be:	c1 e0 10             	shl    $0x10,%eax
801051c1:	09 c1                	or     %eax,%ecx
801051c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801051c6:	c1 e0 08             	shl    $0x8,%eax
801051c9:	09 c8                	or     %ecx,%eax
801051cb:	0b 45 0c             	or     0xc(%ebp),%eax
801051ce:	89 54 24 08          	mov    %edx,0x8(%esp)
801051d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801051d6:	8b 45 08             	mov    0x8(%ebp),%eax
801051d9:	89 04 24             	mov    %eax,(%esp)
801051dc:	e8 84 ff ff ff       	call   80105165 <stosl>
801051e1:	eb 19                	jmp    801051fc <memset+0x72>
  } else
    stosb(dst, c, n);
801051e3:	8b 45 10             	mov    0x10(%ebp),%eax
801051e6:	89 44 24 08          	mov    %eax,0x8(%esp)
801051ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801051f1:	8b 45 08             	mov    0x8(%ebp),%eax
801051f4:	89 04 24             	mov    %eax,(%esp)
801051f7:	e8 44 ff ff ff       	call   80105140 <stosb>
  return dst;
801051fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801051ff:	c9                   	leave  
80105200:	c3                   	ret    

80105201 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105201:	55                   	push   %ebp
80105202:	89 e5                	mov    %esp,%ebp
80105204:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105207:	8b 45 08             	mov    0x8(%ebp),%eax
8010520a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010520d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105210:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105213:	eb 2a                	jmp    8010523f <memcmp+0x3e>
    if(*s1 != *s2)
80105215:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105218:	8a 10                	mov    (%eax),%dl
8010521a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010521d:	8a 00                	mov    (%eax),%al
8010521f:	38 c2                	cmp    %al,%dl
80105221:	74 16                	je     80105239 <memcmp+0x38>
      return *s1 - *s2;
80105223:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105226:	8a 00                	mov    (%eax),%al
80105228:	0f b6 d0             	movzbl %al,%edx
8010522b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010522e:	8a 00                	mov    (%eax),%al
80105230:	0f b6 c0             	movzbl %al,%eax
80105233:	29 c2                	sub    %eax,%edx
80105235:	89 d0                	mov    %edx,%eax
80105237:	eb 18                	jmp    80105251 <memcmp+0x50>
    s1++, s2++;
80105239:	ff 45 fc             	incl   -0x4(%ebp)
8010523c:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010523f:	8b 45 10             	mov    0x10(%ebp),%eax
80105242:	8d 50 ff             	lea    -0x1(%eax),%edx
80105245:	89 55 10             	mov    %edx,0x10(%ebp)
80105248:	85 c0                	test   %eax,%eax
8010524a:	75 c9                	jne    80105215 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010524c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105251:	c9                   	leave  
80105252:	c3                   	ret    

80105253 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105253:	55                   	push   %ebp
80105254:	89 e5                	mov    %esp,%ebp
80105256:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105259:	8b 45 0c             	mov    0xc(%ebp),%eax
8010525c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010525f:	8b 45 08             	mov    0x8(%ebp),%eax
80105262:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105265:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105268:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010526b:	73 3a                	jae    801052a7 <memmove+0x54>
8010526d:	8b 45 10             	mov    0x10(%ebp),%eax
80105270:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105273:	01 d0                	add    %edx,%eax
80105275:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105278:	76 2d                	jbe    801052a7 <memmove+0x54>
    s += n;
8010527a:	8b 45 10             	mov    0x10(%ebp),%eax
8010527d:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105280:	8b 45 10             	mov    0x10(%ebp),%eax
80105283:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105286:	eb 10                	jmp    80105298 <memmove+0x45>
      *--d = *--s;
80105288:	ff 4d f8             	decl   -0x8(%ebp)
8010528b:	ff 4d fc             	decl   -0x4(%ebp)
8010528e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105291:	8a 10                	mov    (%eax),%dl
80105293:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105296:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105298:	8b 45 10             	mov    0x10(%ebp),%eax
8010529b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010529e:	89 55 10             	mov    %edx,0x10(%ebp)
801052a1:	85 c0                	test   %eax,%eax
801052a3:	75 e3                	jne    80105288 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801052a5:	eb 25                	jmp    801052cc <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801052a7:	eb 16                	jmp    801052bf <memmove+0x6c>
      *d++ = *s++;
801052a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052ac:	8d 50 01             	lea    0x1(%eax),%edx
801052af:	89 55 f8             	mov    %edx,-0x8(%ebp)
801052b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052b5:	8d 4a 01             	lea    0x1(%edx),%ecx
801052b8:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801052bb:	8a 12                	mov    (%edx),%dl
801052bd:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801052bf:	8b 45 10             	mov    0x10(%ebp),%eax
801052c2:	8d 50 ff             	lea    -0x1(%eax),%edx
801052c5:	89 55 10             	mov    %edx,0x10(%ebp)
801052c8:	85 c0                	test   %eax,%eax
801052ca:	75 dd                	jne    801052a9 <memmove+0x56>
      *d++ = *s++;

  return dst;
801052cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052cf:	c9                   	leave  
801052d0:	c3                   	ret    

801052d1 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801052d1:	55                   	push   %ebp
801052d2:	89 e5                	mov    %esp,%ebp
801052d4:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801052d7:	8b 45 10             	mov    0x10(%ebp),%eax
801052da:	89 44 24 08          	mov    %eax,0x8(%esp)
801052de:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801052e5:	8b 45 08             	mov    0x8(%ebp),%eax
801052e8:	89 04 24             	mov    %eax,(%esp)
801052eb:	e8 63 ff ff ff       	call   80105253 <memmove>
}
801052f0:	c9                   	leave  
801052f1:	c3                   	ret    

801052f2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801052f2:	55                   	push   %ebp
801052f3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801052f5:	eb 09                	jmp    80105300 <strncmp+0xe>
    n--, p++, q++;
801052f7:	ff 4d 10             	decl   0x10(%ebp)
801052fa:	ff 45 08             	incl   0x8(%ebp)
801052fd:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105300:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105304:	74 17                	je     8010531d <strncmp+0x2b>
80105306:	8b 45 08             	mov    0x8(%ebp),%eax
80105309:	8a 00                	mov    (%eax),%al
8010530b:	84 c0                	test   %al,%al
8010530d:	74 0e                	je     8010531d <strncmp+0x2b>
8010530f:	8b 45 08             	mov    0x8(%ebp),%eax
80105312:	8a 10                	mov    (%eax),%dl
80105314:	8b 45 0c             	mov    0xc(%ebp),%eax
80105317:	8a 00                	mov    (%eax),%al
80105319:	38 c2                	cmp    %al,%dl
8010531b:	74 da                	je     801052f7 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010531d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105321:	75 07                	jne    8010532a <strncmp+0x38>
    return 0;
80105323:	b8 00 00 00 00       	mov    $0x0,%eax
80105328:	eb 14                	jmp    8010533e <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
8010532a:	8b 45 08             	mov    0x8(%ebp),%eax
8010532d:	8a 00                	mov    (%eax),%al
8010532f:	0f b6 d0             	movzbl %al,%edx
80105332:	8b 45 0c             	mov    0xc(%ebp),%eax
80105335:	8a 00                	mov    (%eax),%al
80105337:	0f b6 c0             	movzbl %al,%eax
8010533a:	29 c2                	sub    %eax,%edx
8010533c:	89 d0                	mov    %edx,%eax
}
8010533e:	5d                   	pop    %ebp
8010533f:	c3                   	ret    

80105340 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
80105343:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105346:	8b 45 08             	mov    0x8(%ebp),%eax
80105349:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010534c:	90                   	nop
8010534d:	8b 45 10             	mov    0x10(%ebp),%eax
80105350:	8d 50 ff             	lea    -0x1(%eax),%edx
80105353:	89 55 10             	mov    %edx,0x10(%ebp)
80105356:	85 c0                	test   %eax,%eax
80105358:	7e 1c                	jle    80105376 <strncpy+0x36>
8010535a:	8b 45 08             	mov    0x8(%ebp),%eax
8010535d:	8d 50 01             	lea    0x1(%eax),%edx
80105360:	89 55 08             	mov    %edx,0x8(%ebp)
80105363:	8b 55 0c             	mov    0xc(%ebp),%edx
80105366:	8d 4a 01             	lea    0x1(%edx),%ecx
80105369:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010536c:	8a 12                	mov    (%edx),%dl
8010536e:	88 10                	mov    %dl,(%eax)
80105370:	8a 00                	mov    (%eax),%al
80105372:	84 c0                	test   %al,%al
80105374:	75 d7                	jne    8010534d <strncpy+0xd>
    ;
  while(n-- > 0)
80105376:	eb 0c                	jmp    80105384 <strncpy+0x44>
    *s++ = 0;
80105378:	8b 45 08             	mov    0x8(%ebp),%eax
8010537b:	8d 50 01             	lea    0x1(%eax),%edx
8010537e:	89 55 08             	mov    %edx,0x8(%ebp)
80105381:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105384:	8b 45 10             	mov    0x10(%ebp),%eax
80105387:	8d 50 ff             	lea    -0x1(%eax),%edx
8010538a:	89 55 10             	mov    %edx,0x10(%ebp)
8010538d:	85 c0                	test   %eax,%eax
8010538f:	7f e7                	jg     80105378 <strncpy+0x38>
    *s++ = 0;
  return os;
80105391:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105394:	c9                   	leave  
80105395:	c3                   	ret    

80105396 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105396:	55                   	push   %ebp
80105397:	89 e5                	mov    %esp,%ebp
80105399:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010539c:	8b 45 08             	mov    0x8(%ebp),%eax
8010539f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801053a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053a6:	7f 05                	jg     801053ad <safestrcpy+0x17>
    return os;
801053a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ab:	eb 2e                	jmp    801053db <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
801053ad:	ff 4d 10             	decl   0x10(%ebp)
801053b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053b4:	7e 1c                	jle    801053d2 <safestrcpy+0x3c>
801053b6:	8b 45 08             	mov    0x8(%ebp),%eax
801053b9:	8d 50 01             	lea    0x1(%eax),%edx
801053bc:	89 55 08             	mov    %edx,0x8(%ebp)
801053bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801053c2:	8d 4a 01             	lea    0x1(%edx),%ecx
801053c5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801053c8:	8a 12                	mov    (%edx),%dl
801053ca:	88 10                	mov    %dl,(%eax)
801053cc:	8a 00                	mov    (%eax),%al
801053ce:	84 c0                	test   %al,%al
801053d0:	75 db                	jne    801053ad <safestrcpy+0x17>
    ;
  *s = 0;
801053d2:	8b 45 08             	mov    0x8(%ebp),%eax
801053d5:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801053d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801053db:	c9                   	leave  
801053dc:	c3                   	ret    

801053dd <strlen>:

int
strlen(const char *s)
{
801053dd:	55                   	push   %ebp
801053de:	89 e5                	mov    %esp,%ebp
801053e0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801053e3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801053ea:	eb 03                	jmp    801053ef <strlen+0x12>
801053ec:	ff 45 fc             	incl   -0x4(%ebp)
801053ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053f2:	8b 45 08             	mov    0x8(%ebp),%eax
801053f5:	01 d0                	add    %edx,%eax
801053f7:	8a 00                	mov    (%eax),%al
801053f9:	84 c0                	test   %al,%al
801053fb:	75 ef                	jne    801053ec <strlen+0xf>
    ;
  return n;
801053fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105400:	c9                   	leave  
80105401:	c3                   	ret    
	...

80105404 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105404:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105408:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010540c:	55                   	push   %ebp
  pushl %ebx
8010540d:	53                   	push   %ebx
  pushl %esi
8010540e:	56                   	push   %esi
  pushl %edi
8010540f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105410:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105412:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105414:	5f                   	pop    %edi
  popl %esi
80105415:	5e                   	pop    %esi
  popl %ebx
80105416:	5b                   	pop    %ebx
  popl %ebp
80105417:	5d                   	pop    %ebp
  ret
80105418:	c3                   	ret    
80105419:	00 00                	add    %al,(%eax)
	...

8010541c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010541c:	55                   	push   %ebp
8010541d:	89 e5                	mov    %esp,%ebp
8010541f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105422:	e8 e4 ee ff ff       	call   8010430b <myproc>
80105427:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010542a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010542d:	8b 00                	mov    (%eax),%eax
8010542f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105432:	76 0f                	jbe    80105443 <fetchint+0x27>
80105434:	8b 45 08             	mov    0x8(%ebp),%eax
80105437:	8d 50 04             	lea    0x4(%eax),%edx
8010543a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010543d:	8b 00                	mov    (%eax),%eax
8010543f:	39 c2                	cmp    %eax,%edx
80105441:	76 07                	jbe    8010544a <fetchint+0x2e>
    return -1;
80105443:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105448:	eb 0f                	jmp    80105459 <fetchint+0x3d>
  *ip = *(int*)(addr);
8010544a:	8b 45 08             	mov    0x8(%ebp),%eax
8010544d:	8b 10                	mov    (%eax),%edx
8010544f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105452:	89 10                	mov    %edx,(%eax)
  return 0;
80105454:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105459:	c9                   	leave  
8010545a:	c3                   	ret    

8010545b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010545b:	55                   	push   %ebp
8010545c:	89 e5                	mov    %esp,%ebp
8010545e:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105461:	e8 a5 ee ff ff       	call   8010430b <myproc>
80105466:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105469:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010546c:	8b 00                	mov    (%eax),%eax
8010546e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105471:	77 07                	ja     8010547a <fetchstr+0x1f>
    return -1;
80105473:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105478:	eb 41                	jmp    801054bb <fetchstr+0x60>
  *pp = (char*)addr;
8010547a:	8b 55 08             	mov    0x8(%ebp),%edx
8010547d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105480:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105482:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105485:	8b 00                	mov    (%eax),%eax
80105487:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010548a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010548d:	8b 00                	mov    (%eax),%eax
8010548f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105492:	eb 1a                	jmp    801054ae <fetchstr+0x53>
    if(*s == 0)
80105494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105497:	8a 00                	mov    (%eax),%al
80105499:	84 c0                	test   %al,%al
8010549b:	75 0e                	jne    801054ab <fetchstr+0x50>
      return s - *pp;
8010549d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a3:	8b 00                	mov    (%eax),%eax
801054a5:	29 c2                	sub    %eax,%edx
801054a7:	89 d0                	mov    %edx,%eax
801054a9:	eb 10                	jmp    801054bb <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801054ab:	ff 45 f4             	incl   -0xc(%ebp)
801054ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801054b4:	72 de                	jb     80105494 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801054b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054bb:	c9                   	leave  
801054bc:	c3                   	ret    

801054bd <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801054bd:	55                   	push   %ebp
801054be:	89 e5                	mov    %esp,%ebp
801054c0:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801054c3:	e8 43 ee ff ff       	call   8010430b <myproc>
801054c8:	8b 40 18             	mov    0x18(%eax),%eax
801054cb:	8b 50 44             	mov    0x44(%eax),%edx
801054ce:	8b 45 08             	mov    0x8(%ebp),%eax
801054d1:	c1 e0 02             	shl    $0x2,%eax
801054d4:	01 d0                	add    %edx,%eax
801054d6:	8d 50 04             	lea    0x4(%eax),%edx
801054d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801054dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801054e0:	89 14 24             	mov    %edx,(%esp)
801054e3:	e8 34 ff ff ff       	call   8010541c <fetchint>
}
801054e8:	c9                   	leave  
801054e9:	c3                   	ret    

801054ea <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801054ea:	55                   	push   %ebp
801054eb:	89 e5                	mov    %esp,%ebp
801054ed:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
801054f0:	e8 16 ee ff ff       	call   8010430b <myproc>
801054f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801054f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801054ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105502:	89 04 24             	mov    %eax,(%esp)
80105505:	e8 b3 ff ff ff       	call   801054bd <argint>
8010550a:	85 c0                	test   %eax,%eax
8010550c:	79 07                	jns    80105515 <argptr+0x2b>
    return -1;
8010550e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105513:	eb 3d                	jmp    80105552 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105515:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105519:	78 21                	js     8010553c <argptr+0x52>
8010551b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010551e:	89 c2                	mov    %eax,%edx
80105520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105523:	8b 00                	mov    (%eax),%eax
80105525:	39 c2                	cmp    %eax,%edx
80105527:	73 13                	jae    8010553c <argptr+0x52>
80105529:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010552c:	89 c2                	mov    %eax,%edx
8010552e:	8b 45 10             	mov    0x10(%ebp),%eax
80105531:	01 c2                	add    %eax,%edx
80105533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105536:	8b 00                	mov    (%eax),%eax
80105538:	39 c2                	cmp    %eax,%edx
8010553a:	76 07                	jbe    80105543 <argptr+0x59>
    return -1;
8010553c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105541:	eb 0f                	jmp    80105552 <argptr+0x68>
  *pp = (char*)i;
80105543:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105546:	89 c2                	mov    %eax,%edx
80105548:	8b 45 0c             	mov    0xc(%ebp),%eax
8010554b:	89 10                	mov    %edx,(%eax)
  return 0;
8010554d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105552:	c9                   	leave  
80105553:	c3                   	ret    

80105554 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105554:	55                   	push   %ebp
80105555:	89 e5                	mov    %esp,%ebp
80105557:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010555a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010555d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105561:	8b 45 08             	mov    0x8(%ebp),%eax
80105564:	89 04 24             	mov    %eax,(%esp)
80105567:	e8 51 ff ff ff       	call   801054bd <argint>
8010556c:	85 c0                	test   %eax,%eax
8010556e:	79 07                	jns    80105577 <argstr+0x23>
    return -1;
80105570:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105575:	eb 12                	jmp    80105589 <argstr+0x35>
  return fetchstr(addr, pp);
80105577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010557d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105581:	89 04 24             	mov    %eax,(%esp)
80105584:	e8 d2 fe ff ff       	call   8010545b <fetchstr>
}
80105589:	c9                   	leave  
8010558a:	c3                   	ret    

8010558b <syscall>:
[SYS_container_init] sys_container_init,
};

void
syscall(void)
{
8010558b:	55                   	push   %ebp
8010558c:	89 e5                	mov    %esp,%ebp
8010558e:	53                   	push   %ebx
8010558f:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105592:	e8 74 ed ff ff       	call   8010430b <myproc>
80105597:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010559a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559d:	8b 40 18             	mov    0x18(%eax),%eax
801055a0:	8b 40 1c             	mov    0x1c(%eax),%eax
801055a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801055a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055aa:	7e 2d                	jle    801055d9 <syscall+0x4e>
801055ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055af:	83 f8 27             	cmp    $0x27,%eax
801055b2:	77 25                	ja     801055d9 <syscall+0x4e>
801055b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055b7:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801055be:	85 c0                	test   %eax,%eax
801055c0:	74 17                	je     801055d9 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
801055c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c5:	8b 58 18             	mov    0x18(%eax),%ebx
801055c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055cb:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
801055d2:	ff d0                	call   *%eax
801055d4:	89 43 1c             	mov    %eax,0x1c(%ebx)
801055d7:	eb 34                	jmp    8010560d <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801055d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055dc:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801055df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e2:	8b 40 10             	mov    0x10(%eax),%eax
801055e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
801055ec:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801055f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801055f4:	c7 04 24 7c 8f 10 80 	movl   $0x80108f7c,(%esp)
801055fb:	e8 c1 ad ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105603:	8b 40 18             	mov    0x18(%eax),%eax
80105606:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010560d:	83 c4 24             	add    $0x24,%esp
80105610:	5b                   	pop    %ebx
80105611:	5d                   	pop    %ebp
80105612:	c3                   	ret    
	...

80105614 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105614:	55                   	push   %ebp
80105615:	89 e5                	mov    %esp,%ebp
80105617:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010561a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010561d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105621:	8b 45 08             	mov    0x8(%ebp),%eax
80105624:	89 04 24             	mov    %eax,(%esp)
80105627:	e8 91 fe ff ff       	call   801054bd <argint>
8010562c:	85 c0                	test   %eax,%eax
8010562e:	79 07                	jns    80105637 <argfd+0x23>
    return -1;
80105630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105635:	eb 4f                	jmp    80105686 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105637:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010563a:	85 c0                	test   %eax,%eax
8010563c:	78 20                	js     8010565e <argfd+0x4a>
8010563e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105641:	83 f8 0f             	cmp    $0xf,%eax
80105644:	7f 18                	jg     8010565e <argfd+0x4a>
80105646:	e8 c0 ec ff ff       	call   8010430b <myproc>
8010564b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010564e:	83 c2 08             	add    $0x8,%edx
80105651:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105655:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105658:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010565c:	75 07                	jne    80105665 <argfd+0x51>
    return -1;
8010565e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105663:	eb 21                	jmp    80105686 <argfd+0x72>
  if(pfd)
80105665:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105669:	74 08                	je     80105673 <argfd+0x5f>
    *pfd = fd;
8010566b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010566e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105671:	89 10                	mov    %edx,(%eax)
  if(pf)
80105673:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105677:	74 08                	je     80105681 <argfd+0x6d>
    *pf = f;
80105679:	8b 45 10             	mov    0x10(%ebp),%eax
8010567c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010567f:	89 10                	mov    %edx,(%eax)
  return 0;
80105681:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105686:	c9                   	leave  
80105687:	c3                   	ret    

80105688 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105688:	55                   	push   %ebp
80105689:	89 e5                	mov    %esp,%ebp
8010568b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010568e:	e8 78 ec ff ff       	call   8010430b <myproc>
80105693:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105696:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010569d:	eb 29                	jmp    801056c8 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
8010569f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056a5:	83 c2 08             	add    $0x8,%edx
801056a8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801056ac:	85 c0                	test   %eax,%eax
801056ae:	75 15                	jne    801056c5 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801056b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056b6:	8d 4a 08             	lea    0x8(%edx),%ecx
801056b9:	8b 55 08             	mov    0x8(%ebp),%edx
801056bc:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801056c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c3:	eb 0e                	jmp    801056d3 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801056c5:	ff 45 f4             	incl   -0xc(%ebp)
801056c8:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801056cc:	7e d1                	jle    8010569f <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801056ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056d3:	c9                   	leave  
801056d4:	c3                   	ret    

801056d5 <sys_dup>:

int
sys_dup(void)
{
801056d5:	55                   	push   %ebp
801056d6:	89 e5                	mov    %esp,%ebp
801056d8:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801056db:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056de:	89 44 24 08          	mov    %eax,0x8(%esp)
801056e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056e9:	00 
801056ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056f1:	e8 1e ff ff ff       	call   80105614 <argfd>
801056f6:	85 c0                	test   %eax,%eax
801056f8:	79 07                	jns    80105701 <sys_dup+0x2c>
    return -1;
801056fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ff:	eb 29                	jmp    8010572a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105701:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105704:	89 04 24             	mov    %eax,(%esp)
80105707:	e8 7c ff ff ff       	call   80105688 <fdalloc>
8010570c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010570f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105713:	79 07                	jns    8010571c <sys_dup+0x47>
    return -1;
80105715:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010571a:	eb 0e                	jmp    8010572a <sys_dup+0x55>
  filedup(f);
8010571c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010571f:	89 04 24             	mov    %eax,(%esp)
80105722:	e8 23 ba ff ff       	call   8010114a <filedup>
  return fd;
80105727:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010572a:	c9                   	leave  
8010572b:	c3                   	ret    

8010572c <sys_read>:

int
sys_read(void)
{
8010572c:	55                   	push   %ebp
8010572d:	89 e5                	mov    %esp,%ebp
8010572f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105732:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105735:	89 44 24 08          	mov    %eax,0x8(%esp)
80105739:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105740:	00 
80105741:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105748:	e8 c7 fe ff ff       	call   80105614 <argfd>
8010574d:	85 c0                	test   %eax,%eax
8010574f:	78 35                	js     80105786 <sys_read+0x5a>
80105751:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105754:	89 44 24 04          	mov    %eax,0x4(%esp)
80105758:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010575f:	e8 59 fd ff ff       	call   801054bd <argint>
80105764:	85 c0                	test   %eax,%eax
80105766:	78 1e                	js     80105786 <sys_read+0x5a>
80105768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010576f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105772:	89 44 24 04          	mov    %eax,0x4(%esp)
80105776:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010577d:	e8 68 fd ff ff       	call   801054ea <argptr>
80105782:	85 c0                	test   %eax,%eax
80105784:	79 07                	jns    8010578d <sys_read+0x61>
    return -1;
80105786:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578b:	eb 19                	jmp    801057a6 <sys_read+0x7a>
  return fileread(f, p, n);
8010578d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105790:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105796:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010579a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010579e:	89 04 24             	mov    %eax,(%esp)
801057a1:	e8 05 bb ff ff       	call   801012ab <fileread>
}
801057a6:	c9                   	leave  
801057a7:	c3                   	ret    

801057a8 <sys_write>:

int
sys_write(void)
{
801057a8:	55                   	push   %ebp
801057a9:	89 e5                	mov    %esp,%ebp
801057ab:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801057ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057b1:	89 44 24 08          	mov    %eax,0x8(%esp)
801057b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057bc:	00 
801057bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057c4:	e8 4b fe ff ff       	call   80105614 <argfd>
801057c9:	85 c0                	test   %eax,%eax
801057cb:	78 35                	js     80105802 <sys_write+0x5a>
801057cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801057d4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801057db:	e8 dd fc ff ff       	call   801054bd <argint>
801057e0:	85 c0                	test   %eax,%eax
801057e2:	78 1e                	js     80105802 <sys_write+0x5a>
801057e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e7:	89 44 24 08          	mov    %eax,0x8(%esp)
801057eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801057f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801057f9:	e8 ec fc ff ff       	call   801054ea <argptr>
801057fe:	85 c0                	test   %eax,%eax
80105800:	79 07                	jns    80105809 <sys_write+0x61>
    return -1;
80105802:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105807:	eb 19                	jmp    80105822 <sys_write+0x7a>
  return filewrite(f, p, n);
80105809:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010580c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010580f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105812:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105816:	89 54 24 04          	mov    %edx,0x4(%esp)
8010581a:	89 04 24             	mov    %eax,(%esp)
8010581d:	e8 44 bb ff ff       	call   80101366 <filewrite>
}
80105822:	c9                   	leave  
80105823:	c3                   	ret    

80105824 <sys_close>:

int
sys_close(void)
{
80105824:	55                   	push   %ebp
80105825:	89 e5                	mov    %esp,%ebp
80105827:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010582a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010582d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105831:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105834:	89 44 24 04          	mov    %eax,0x4(%esp)
80105838:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010583f:	e8 d0 fd ff ff       	call   80105614 <argfd>
80105844:	85 c0                	test   %eax,%eax
80105846:	79 07                	jns    8010584f <sys_close+0x2b>
    return -1;
80105848:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010584d:	eb 23                	jmp    80105872 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
8010584f:	e8 b7 ea ff ff       	call   8010430b <myproc>
80105854:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105857:	83 c2 08             	add    $0x8,%edx
8010585a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105861:	00 
  fileclose(f);
80105862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105865:	89 04 24             	mov    %eax,(%esp)
80105868:	e8 25 b9 ff ff       	call   80101192 <fileclose>
  return 0;
8010586d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105872:	c9                   	leave  
80105873:	c3                   	ret    

80105874 <sys_fstat>:

int
sys_fstat(void)
{
80105874:	55                   	push   %ebp
80105875:	89 e5                	mov    %esp,%ebp
80105877:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010587a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010587d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105881:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105888:	00 
80105889:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105890:	e8 7f fd ff ff       	call   80105614 <argfd>
80105895:	85 c0                	test   %eax,%eax
80105897:	78 1f                	js     801058b8 <sys_fstat+0x44>
80105899:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801058a0:	00 
801058a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801058a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058af:	e8 36 fc ff ff       	call   801054ea <argptr>
801058b4:	85 c0                	test   %eax,%eax
801058b6:	79 07                	jns    801058bf <sys_fstat+0x4b>
    return -1;
801058b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bd:	eb 12                	jmp    801058d1 <sys_fstat+0x5d>
  return filestat(f, st);
801058bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801058c9:	89 04 24             	mov    %eax,(%esp)
801058cc:	e8 8b b9 ff ff       	call   8010125c <filestat>
}
801058d1:	c9                   	leave  
801058d2:	c3                   	ret    

801058d3 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801058d3:	55                   	push   %ebp
801058d4:	89 e5                	mov    %esp,%ebp
801058d6:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801058d9:	8d 45 d8             	lea    -0x28(%ebp),%eax
801058dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801058e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058e7:	e8 68 fc ff ff       	call   80105554 <argstr>
801058ec:	85 c0                	test   %eax,%eax
801058ee:	78 17                	js     80105907 <sys_link+0x34>
801058f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801058f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058fe:	e8 51 fc ff ff       	call   80105554 <argstr>
80105903:	85 c0                	test   %eax,%eax
80105905:	79 0a                	jns    80105911 <sys_link+0x3e>
    return -1;
80105907:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010590c:	e9 3d 01 00 00       	jmp    80105a4e <sys_link+0x17b>

  begin_op();
80105911:	e8 fd dc ff ff       	call   80103613 <begin_op>
  if((ip = namei(old)) == 0){
80105916:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105919:	89 04 24             	mov    %eax,(%esp)
8010591c:	e8 1e cd ff ff       	call   8010263f <namei>
80105921:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105924:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105928:	75 0f                	jne    80105939 <sys_link+0x66>
    end_op();
8010592a:	e8 66 dd ff ff       	call   80103695 <end_op>
    return -1;
8010592f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105934:	e9 15 01 00 00       	jmp    80105a4e <sys_link+0x17b>
  }

  ilock(ip);
80105939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593c:	89 04 24             	mov    %eax,(%esp)
8010593f:	e8 d6 c1 ff ff       	call   80101b1a <ilock>
  if(ip->type == T_DIR){
80105944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105947:	8b 40 50             	mov    0x50(%eax),%eax
8010594a:	66 83 f8 01          	cmp    $0x1,%ax
8010594e:	75 1a                	jne    8010596a <sys_link+0x97>
    iunlockput(ip);
80105950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105953:	89 04 24             	mov    %eax,(%esp)
80105956:	e8 be c3 ff ff       	call   80101d19 <iunlockput>
    end_op();
8010595b:	e8 35 dd ff ff       	call   80103695 <end_op>
    return -1;
80105960:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105965:	e9 e4 00 00 00       	jmp    80105a4e <sys_link+0x17b>
  }

  ip->nlink++;
8010596a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010596d:	66 8b 40 56          	mov    0x56(%eax),%ax
80105971:	40                   	inc    %eax
80105972:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105975:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597c:	89 04 24             	mov    %eax,(%esp)
8010597f:	e8 d3 bf ff ff       	call   80101957 <iupdate>
  iunlock(ip);
80105984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105987:	89 04 24             	mov    %eax,(%esp)
8010598a:	e8 95 c2 ff ff       	call   80101c24 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010598f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105992:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105995:	89 54 24 04          	mov    %edx,0x4(%esp)
80105999:	89 04 24             	mov    %eax,(%esp)
8010599c:	e8 c0 cc ff ff       	call   80102661 <nameiparent>
801059a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059a8:	75 02                	jne    801059ac <sys_link+0xd9>
    goto bad;
801059aa:	eb 68                	jmp    80105a14 <sys_link+0x141>
  ilock(dp);
801059ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059af:	89 04 24             	mov    %eax,(%esp)
801059b2:	e8 63 c1 ff ff       	call   80101b1a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801059b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ba:	8b 10                	mov    (%eax),%edx
801059bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bf:	8b 00                	mov    (%eax),%eax
801059c1:	39 c2                	cmp    %eax,%edx
801059c3:	75 20                	jne    801059e5 <sys_link+0x112>
801059c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c8:	8b 40 04             	mov    0x4(%eax),%eax
801059cb:	89 44 24 08          	mov    %eax,0x8(%esp)
801059cf:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801059d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801059d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d9:	89 04 24             	mov    %eax,(%esp)
801059dc:	e8 ab c9 ff ff       	call   8010238c <dirlink>
801059e1:	85 c0                	test   %eax,%eax
801059e3:	79 0d                	jns    801059f2 <sys_link+0x11f>
    iunlockput(dp);
801059e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e8:	89 04 24             	mov    %eax,(%esp)
801059eb:	e8 29 c3 ff ff       	call   80101d19 <iunlockput>
    goto bad;
801059f0:	eb 22                	jmp    80105a14 <sys_link+0x141>
  }
  iunlockput(dp);
801059f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f5:	89 04 24             	mov    %eax,(%esp)
801059f8:	e8 1c c3 ff ff       	call   80101d19 <iunlockput>
  iput(ip);
801059fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a00:	89 04 24             	mov    %eax,(%esp)
80105a03:	e8 60 c2 ff ff       	call   80101c68 <iput>

  end_op();
80105a08:	e8 88 dc ff ff       	call   80103695 <end_op>

  return 0;
80105a0d:	b8 00 00 00 00       	mov    $0x0,%eax
80105a12:	eb 3a                	jmp    80105a4e <sys_link+0x17b>

bad:
  ilock(ip);
80105a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a17:	89 04 24             	mov    %eax,(%esp)
80105a1a:	e8 fb c0 ff ff       	call   80101b1a <ilock>
  ip->nlink--;
80105a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a22:	66 8b 40 56          	mov    0x56(%eax),%ax
80105a26:	48                   	dec    %eax
80105a27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a2a:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a31:	89 04 24             	mov    %eax,(%esp)
80105a34:	e8 1e bf ff ff       	call   80101957 <iupdate>
  iunlockput(ip);
80105a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3c:	89 04 24             	mov    %eax,(%esp)
80105a3f:	e8 d5 c2 ff ff       	call   80101d19 <iunlockput>
  end_op();
80105a44:	e8 4c dc ff ff       	call   80103695 <end_op>
  return -1;
80105a49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a4e:	c9                   	leave  
80105a4f:	c3                   	ret    

80105a50 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105a50:	55                   	push   %ebp
80105a51:	89 e5                	mov    %esp,%ebp
80105a53:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a56:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105a5d:	eb 4a                	jmp    80105aa9 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a62:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105a69:	00 
80105a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a71:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a75:	8b 45 08             	mov    0x8(%ebp),%eax
80105a78:	89 04 24             	mov    %eax,(%esp)
80105a7b:	e8 31 c5 ff ff       	call   80101fb1 <readi>
80105a80:	83 f8 10             	cmp    $0x10,%eax
80105a83:	74 0c                	je     80105a91 <isdirempty+0x41>
      panic("isdirempty: readi");
80105a85:	c7 04 24 98 8f 10 80 	movl   $0x80108f98,(%esp)
80105a8c:	e8 c3 aa ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a94:	66 85 c0             	test   %ax,%ax
80105a97:	74 07                	je     80105aa0 <isdirempty+0x50>
      return 0;
80105a99:	b8 00 00 00 00       	mov    $0x0,%eax
80105a9e:	eb 1b                	jmp    80105abb <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa3:	83 c0 10             	add    $0x10,%eax
80105aa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aa9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aac:	8b 45 08             	mov    0x8(%ebp),%eax
80105aaf:	8b 40 58             	mov    0x58(%eax),%eax
80105ab2:	39 c2                	cmp    %eax,%edx
80105ab4:	72 a9                	jb     80105a5f <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105ab6:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105abb:	c9                   	leave  
80105abc:	c3                   	ret    

80105abd <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105abd:	55                   	push   %ebp
80105abe:	89 e5                	mov    %esp,%ebp
80105ac0:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ac3:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ad1:	e8 7e fa ff ff       	call   80105554 <argstr>
80105ad6:	85 c0                	test   %eax,%eax
80105ad8:	79 0a                	jns    80105ae4 <sys_unlink+0x27>
    return -1;
80105ada:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adf:	e9 a9 01 00 00       	jmp    80105c8d <sys_unlink+0x1d0>

  begin_op();
80105ae4:	e8 2a db ff ff       	call   80103613 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ae9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105aec:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105aef:	89 54 24 04          	mov    %edx,0x4(%esp)
80105af3:	89 04 24             	mov    %eax,(%esp)
80105af6:	e8 66 cb ff ff       	call   80102661 <nameiparent>
80105afb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105afe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b02:	75 0f                	jne    80105b13 <sys_unlink+0x56>
    end_op();
80105b04:	e8 8c db ff ff       	call   80103695 <end_op>
    return -1;
80105b09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b0e:	e9 7a 01 00 00       	jmp    80105c8d <sys_unlink+0x1d0>
  }

  ilock(dp);
80105b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b16:	89 04 24             	mov    %eax,(%esp)
80105b19:	e8 fc bf ff ff       	call   80101b1a <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105b1e:	c7 44 24 04 aa 8f 10 	movl   $0x80108faa,0x4(%esp)
80105b25:	80 
80105b26:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b29:	89 04 24             	mov    %eax,(%esp)
80105b2c:	e8 73 c7 ff ff       	call   801022a4 <namecmp>
80105b31:	85 c0                	test   %eax,%eax
80105b33:	0f 84 3f 01 00 00    	je     80105c78 <sys_unlink+0x1bb>
80105b39:	c7 44 24 04 ac 8f 10 	movl   $0x80108fac,0x4(%esp)
80105b40:	80 
80105b41:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b44:	89 04 24             	mov    %eax,(%esp)
80105b47:	e8 58 c7 ff ff       	call   801022a4 <namecmp>
80105b4c:	85 c0                	test   %eax,%eax
80105b4e:	0f 84 24 01 00 00    	je     80105c78 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105b54:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105b57:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b5b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b65:	89 04 24             	mov    %eax,(%esp)
80105b68:	e8 59 c7 ff ff       	call   801022c6 <dirlookup>
80105b6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b74:	75 05                	jne    80105b7b <sys_unlink+0xbe>
    goto bad;
80105b76:	e9 fd 00 00 00       	jmp    80105c78 <sys_unlink+0x1bb>
  ilock(ip);
80105b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7e:	89 04 24             	mov    %eax,(%esp)
80105b81:	e8 94 bf ff ff       	call   80101b1a <ilock>

  if(ip->nlink < 1)
80105b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b89:	66 8b 40 56          	mov    0x56(%eax),%ax
80105b8d:	66 85 c0             	test   %ax,%ax
80105b90:	7f 0c                	jg     80105b9e <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105b92:	c7 04 24 af 8f 10 80 	movl   $0x80108faf,(%esp)
80105b99:	e8 b6 a9 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba1:	8b 40 50             	mov    0x50(%eax),%eax
80105ba4:	66 83 f8 01          	cmp    $0x1,%ax
80105ba8:	75 1f                	jne    80105bc9 <sys_unlink+0x10c>
80105baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bad:	89 04 24             	mov    %eax,(%esp)
80105bb0:	e8 9b fe ff ff       	call   80105a50 <isdirempty>
80105bb5:	85 c0                	test   %eax,%eax
80105bb7:	75 10                	jne    80105bc9 <sys_unlink+0x10c>
    iunlockput(ip);
80105bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbc:	89 04 24             	mov    %eax,(%esp)
80105bbf:	e8 55 c1 ff ff       	call   80101d19 <iunlockput>
    goto bad;
80105bc4:	e9 af 00 00 00       	jmp    80105c78 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105bc9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105bd0:	00 
80105bd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105bd8:	00 
80105bd9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bdc:	89 04 24             	mov    %eax,(%esp)
80105bdf:	e8 a6 f5 ff ff       	call   8010518a <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105be4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105be7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105bee:	00 
80105bef:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bf3:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfd:	89 04 24             	mov    %eax,(%esp)
80105c00:	e8 10 c5 ff ff       	call   80102115 <writei>
80105c05:	83 f8 10             	cmp    $0x10,%eax
80105c08:	74 0c                	je     80105c16 <sys_unlink+0x159>
    panic("unlink: writei");
80105c0a:	c7 04 24 c1 8f 10 80 	movl   $0x80108fc1,(%esp)
80105c11:	e8 3e a9 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c19:	8b 40 50             	mov    0x50(%eax),%eax
80105c1c:	66 83 f8 01          	cmp    $0x1,%ax
80105c20:	75 1a                	jne    80105c3c <sys_unlink+0x17f>
    dp->nlink--;
80105c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c25:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c29:	48                   	dec    %eax
80105c2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c2d:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c34:	89 04 24             	mov    %eax,(%esp)
80105c37:	e8 1b bd ff ff       	call   80101957 <iupdate>
  }
  iunlockput(dp);
80105c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3f:	89 04 24             	mov    %eax,(%esp)
80105c42:	e8 d2 c0 ff ff       	call   80101d19 <iunlockput>

  ip->nlink--;
80105c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c4a:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c4e:	48                   	dec    %eax
80105c4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c52:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c59:	89 04 24             	mov    %eax,(%esp)
80105c5c:	e8 f6 bc ff ff       	call   80101957 <iupdate>
  iunlockput(ip);
80105c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c64:	89 04 24             	mov    %eax,(%esp)
80105c67:	e8 ad c0 ff ff       	call   80101d19 <iunlockput>

  end_op();
80105c6c:	e8 24 da ff ff       	call   80103695 <end_op>

  return 0;
80105c71:	b8 00 00 00 00       	mov    $0x0,%eax
80105c76:	eb 15                	jmp    80105c8d <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7b:	89 04 24             	mov    %eax,(%esp)
80105c7e:	e8 96 c0 ff ff       	call   80101d19 <iunlockput>
  end_op();
80105c83:	e8 0d da ff ff       	call   80103695 <end_op>
  return -1;
80105c88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c8d:	c9                   	leave  
80105c8e:	c3                   	ret    

80105c8f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105c8f:	55                   	push   %ebp
80105c90:	89 e5                	mov    %esp,%ebp
80105c92:	83 ec 48             	sub    $0x48,%esp
80105c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c98:	8b 55 10             	mov    0x10(%ebp),%edx
80105c9b:	8b 45 14             	mov    0x14(%ebp),%eax
80105c9e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105ca2:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105ca6:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105caa:	8d 45 de             	lea    -0x22(%ebp),%eax
80105cad:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb4:	89 04 24             	mov    %eax,(%esp)
80105cb7:	e8 a5 c9 ff ff       	call   80102661 <nameiparent>
80105cbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc3:	75 0a                	jne    80105ccf <create+0x40>
    return 0;
80105cc5:	b8 00 00 00 00       	mov    $0x0,%eax
80105cca:	e9 79 01 00 00       	jmp    80105e48 <create+0x1b9>
  ilock(dp);
80105ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd2:	89 04 24             	mov    %eax,(%esp)
80105cd5:	e8 40 be ff ff       	call   80101b1a <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105cda:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cdd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce1:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ceb:	89 04 24             	mov    %eax,(%esp)
80105cee:	e8 d3 c5 ff ff       	call   801022c6 <dirlookup>
80105cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cf6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cfa:	74 46                	je     80105d42 <create+0xb3>
    iunlockput(dp);
80105cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cff:	89 04 24             	mov    %eax,(%esp)
80105d02:	e8 12 c0 ff ff       	call   80101d19 <iunlockput>
    ilock(ip);
80105d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0a:	89 04 24             	mov    %eax,(%esp)
80105d0d:	e8 08 be ff ff       	call   80101b1a <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105d12:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105d17:	75 14                	jne    80105d2d <create+0x9e>
80105d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1c:	8b 40 50             	mov    0x50(%eax),%eax
80105d1f:	66 83 f8 02          	cmp    $0x2,%ax
80105d23:	75 08                	jne    80105d2d <create+0x9e>
      return ip;
80105d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d28:	e9 1b 01 00 00       	jmp    80105e48 <create+0x1b9>
    iunlockput(ip);
80105d2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d30:	89 04 24             	mov    %eax,(%esp)
80105d33:	e8 e1 bf ff ff       	call   80101d19 <iunlockput>
    return 0;
80105d38:	b8 00 00 00 00       	mov    $0x0,%eax
80105d3d:	e9 06 01 00 00       	jmp    80105e48 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105d42:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d49:	8b 00                	mov    (%eax),%eax
80105d4b:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d4f:	89 04 24             	mov    %eax,(%esp)
80105d52:	e8 2e bb ff ff       	call   80101885 <ialloc>
80105d57:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d5e:	75 0c                	jne    80105d6c <create+0xdd>
    panic("create: ialloc");
80105d60:	c7 04 24 d0 8f 10 80 	movl   $0x80108fd0,(%esp)
80105d67:	e8 e8 a7 ff ff       	call   80100554 <panic>

  ilock(ip);
80105d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6f:	89 04 24             	mov    %eax,(%esp)
80105d72:	e8 a3 bd ff ff       	call   80101b1a <ilock>
  ip->major = major;
80105d77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105d7d:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80105d81:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d84:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d87:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80105d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8e:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d97:	89 04 24             	mov    %eax,(%esp)
80105d9a:	e8 b8 bb ff ff       	call   80101957 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105d9f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105da4:	75 68                	jne    80105e0e <create+0x17f>
    dp->nlink++;  // for ".."
80105da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da9:	66 8b 40 56          	mov    0x56(%eax),%ax
80105dad:	40                   	inc    %eax
80105dae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105db1:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db8:	89 04 24             	mov    %eax,(%esp)
80105dbb:	e8 97 bb ff ff       	call   80101957 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc3:	8b 40 04             	mov    0x4(%eax),%eax
80105dc6:	89 44 24 08          	mov    %eax,0x8(%esp)
80105dca:	c7 44 24 04 aa 8f 10 	movl   $0x80108faa,0x4(%esp)
80105dd1:	80 
80105dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd5:	89 04 24             	mov    %eax,(%esp)
80105dd8:	e8 af c5 ff ff       	call   8010238c <dirlink>
80105ddd:	85 c0                	test   %eax,%eax
80105ddf:	78 21                	js     80105e02 <create+0x173>
80105de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de4:	8b 40 04             	mov    0x4(%eax),%eax
80105de7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105deb:	c7 44 24 04 ac 8f 10 	movl   $0x80108fac,0x4(%esp)
80105df2:	80 
80105df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df6:	89 04 24             	mov    %eax,(%esp)
80105df9:	e8 8e c5 ff ff       	call   8010238c <dirlink>
80105dfe:	85 c0                	test   %eax,%eax
80105e00:	79 0c                	jns    80105e0e <create+0x17f>
      panic("create dots");
80105e02:	c7 04 24 df 8f 10 80 	movl   $0x80108fdf,(%esp)
80105e09:	e8 46 a7 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e11:	8b 40 04             	mov    0x4(%eax),%eax
80105e14:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e18:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e22:	89 04 24             	mov    %eax,(%esp)
80105e25:	e8 62 c5 ff ff       	call   8010238c <dirlink>
80105e2a:	85 c0                	test   %eax,%eax
80105e2c:	79 0c                	jns    80105e3a <create+0x1ab>
    panic("create: dirlink");
80105e2e:	c7 04 24 eb 8f 10 80 	movl   $0x80108feb,(%esp)
80105e35:	e8 1a a7 ff ff       	call   80100554 <panic>

  iunlockput(dp);
80105e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3d:	89 04 24             	mov    %eax,(%esp)
80105e40:	e8 d4 be ff ff       	call   80101d19 <iunlockput>

  return ip;
80105e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105e48:	c9                   	leave  
80105e49:	c3                   	ret    

80105e4a <sys_open>:

int
sys_open(void)
{
80105e4a:	55                   	push   %ebp
80105e4b:	89 e5                	mov    %esp,%ebp
80105e4d:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105e50:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e53:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e5e:	e8 f1 f6 ff ff       	call   80105554 <argstr>
80105e63:	85 c0                	test   %eax,%eax
80105e65:	78 17                	js     80105e7e <sys_open+0x34>
80105e67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e6e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e75:	e8 43 f6 ff ff       	call   801054bd <argint>
80105e7a:	85 c0                	test   %eax,%eax
80105e7c:	79 0a                	jns    80105e88 <sys_open+0x3e>
    return -1;
80105e7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e83:	e9 64 01 00 00       	jmp    80105fec <sys_open+0x1a2>

  begin_op();
80105e88:	e8 86 d7 ff ff       	call   80103613 <begin_op>

  if(omode & O_CREATE){
80105e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e90:	25 00 02 00 00       	and    $0x200,%eax
80105e95:	85 c0                	test   %eax,%eax
80105e97:	74 3b                	je     80105ed4 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105e99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e9c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105ea3:	00 
80105ea4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105eab:	00 
80105eac:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105eb3:	00 
80105eb4:	89 04 24             	mov    %eax,(%esp)
80105eb7:	e8 d3 fd ff ff       	call   80105c8f <create>
80105ebc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ebf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ec3:	75 6a                	jne    80105f2f <sys_open+0xe5>
      end_op();
80105ec5:	e8 cb d7 ff ff       	call   80103695 <end_op>
      return -1;
80105eca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ecf:	e9 18 01 00 00       	jmp    80105fec <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ed7:	89 04 24             	mov    %eax,(%esp)
80105eda:	e8 60 c7 ff ff       	call   8010263f <namei>
80105edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ee2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ee6:	75 0f                	jne    80105ef7 <sys_open+0xad>
      end_op();
80105ee8:	e8 a8 d7 ff ff       	call   80103695 <end_op>
      return -1;
80105eed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef2:	e9 f5 00 00 00       	jmp    80105fec <sys_open+0x1a2>
    }
    ilock(ip);
80105ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efa:	89 04 24             	mov    %eax,(%esp)
80105efd:	e8 18 bc ff ff       	call   80101b1a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f05:	8b 40 50             	mov    0x50(%eax),%eax
80105f08:	66 83 f8 01          	cmp    $0x1,%ax
80105f0c:	75 21                	jne    80105f2f <sys_open+0xe5>
80105f0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f11:	85 c0                	test   %eax,%eax
80105f13:	74 1a                	je     80105f2f <sys_open+0xe5>
      iunlockput(ip);
80105f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f18:	89 04 24             	mov    %eax,(%esp)
80105f1b:	e8 f9 bd ff ff       	call   80101d19 <iunlockput>
      end_op();
80105f20:	e8 70 d7 ff ff       	call   80103695 <end_op>
      return -1;
80105f25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f2a:	e9 bd 00 00 00       	jmp    80105fec <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105f2f:	e8 b6 b1 ff ff       	call   801010ea <filealloc>
80105f34:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f3b:	74 14                	je     80105f51 <sys_open+0x107>
80105f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f40:	89 04 24             	mov    %eax,(%esp)
80105f43:	e8 40 f7 ff ff       	call   80105688 <fdalloc>
80105f48:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105f4b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105f4f:	79 28                	jns    80105f79 <sys_open+0x12f>
    if(f)
80105f51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f55:	74 0b                	je     80105f62 <sys_open+0x118>
      fileclose(f);
80105f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5a:	89 04 24             	mov    %eax,(%esp)
80105f5d:	e8 30 b2 ff ff       	call   80101192 <fileclose>
    iunlockput(ip);
80105f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f65:	89 04 24             	mov    %eax,(%esp)
80105f68:	e8 ac bd ff ff       	call   80101d19 <iunlockput>
    end_op();
80105f6d:	e8 23 d7 ff ff       	call   80103695 <end_op>
    return -1;
80105f72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f77:	eb 73                	jmp    80105fec <sys_open+0x1a2>
  }
  iunlock(ip);
80105f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7c:	89 04 24             	mov    %eax,(%esp)
80105f7f:	e8 a0 bc ff ff       	call   80101c24 <iunlock>
  end_op();
80105f84:	e8 0c d7 ff ff       	call   80103695 <end_op>

  f->type = FD_INODE;
80105f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f98:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105fa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa8:	83 e0 01             	and    $0x1,%eax
80105fab:	85 c0                	test   %eax,%eax
80105fad:	0f 94 c0             	sete   %al
80105fb0:	88 c2                	mov    %al,%dl
80105fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fbb:	83 e0 01             	and    $0x1,%eax
80105fbe:	85 c0                	test   %eax,%eax
80105fc0:	75 0a                	jne    80105fcc <sys_open+0x182>
80105fc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fc5:	83 e0 02             	and    $0x2,%eax
80105fc8:	85 c0                	test   %eax,%eax
80105fca:	74 07                	je     80105fd3 <sys_open+0x189>
80105fcc:	b8 01 00 00 00       	mov    $0x1,%eax
80105fd1:	eb 05                	jmp    80105fd8 <sys_open+0x18e>
80105fd3:	b8 00 00 00 00       	mov    $0x0,%eax
80105fd8:	88 c2                	mov    %al,%dl
80105fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fdd:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
80105fe0:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe6:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
80105fe9:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105fec:	c9                   	leave  
80105fed:	c3                   	ret    

80105fee <sys_mkdir>:

int
sys_mkdir(void)
{
80105fee:	55                   	push   %ebp
80105fef:	89 e5                	mov    %esp,%ebp
80105ff1:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105ff4:	e8 1a d6 ff ff       	call   80103613 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105ff9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ffc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106000:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106007:	e8 48 f5 ff ff       	call   80105554 <argstr>
8010600c:	85 c0                	test   %eax,%eax
8010600e:	78 2c                	js     8010603c <sys_mkdir+0x4e>
80106010:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106013:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010601a:	00 
8010601b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106022:	00 
80106023:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010602a:	00 
8010602b:	89 04 24             	mov    %eax,(%esp)
8010602e:	e8 5c fc ff ff       	call   80105c8f <create>
80106033:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106036:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010603a:	75 0c                	jne    80106048 <sys_mkdir+0x5a>
    end_op();
8010603c:	e8 54 d6 ff ff       	call   80103695 <end_op>
    return -1;
80106041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106046:	eb 15                	jmp    8010605d <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604b:	89 04 24             	mov    %eax,(%esp)
8010604e:	e8 c6 bc ff ff       	call   80101d19 <iunlockput>
  end_op();
80106053:	e8 3d d6 ff ff       	call   80103695 <end_op>
  return 0;
80106058:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010605d:	c9                   	leave  
8010605e:	c3                   	ret    

8010605f <sys_mknod>:

int
sys_mknod(void)
{
8010605f:	55                   	push   %ebp
80106060:	89 e5                	mov    %esp,%ebp
80106062:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106065:	e8 a9 d5 ff ff       	call   80103613 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010606a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010606d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106071:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106078:	e8 d7 f4 ff ff       	call   80105554 <argstr>
8010607d:	85 c0                	test   %eax,%eax
8010607f:	78 5e                	js     801060df <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106081:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106084:	89 44 24 04          	mov    %eax,0x4(%esp)
80106088:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010608f:	e8 29 f4 ff ff       	call   801054bd <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106094:	85 c0                	test   %eax,%eax
80106096:	78 47                	js     801060df <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106098:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010609b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010609f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801060a6:	e8 12 f4 ff ff       	call   801054bd <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801060ab:	85 c0                	test   %eax,%eax
801060ad:	78 30                	js     801060df <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801060af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060b2:	0f bf c8             	movswl %ax,%ecx
801060b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801060b8:	0f bf d0             	movswl %ax,%edx
801060bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801060be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801060c2:	89 54 24 08          	mov    %edx,0x8(%esp)
801060c6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801060cd:	00 
801060ce:	89 04 24             	mov    %eax,(%esp)
801060d1:	e8 b9 fb ff ff       	call   80105c8f <create>
801060d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060dd:	75 0c                	jne    801060eb <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801060df:	e8 b1 d5 ff ff       	call   80103695 <end_op>
    return -1;
801060e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e9:	eb 15                	jmp    80106100 <sys_mknod+0xa1>
  }
  iunlockput(ip);
801060eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ee:	89 04 24             	mov    %eax,(%esp)
801060f1:	e8 23 bc ff ff       	call   80101d19 <iunlockput>
  end_op();
801060f6:	e8 9a d5 ff ff       	call   80103695 <end_op>
  return 0;
801060fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106100:	c9                   	leave  
80106101:	c3                   	ret    

80106102 <sys_chdir>:

int
sys_chdir(void)
{
80106102:	55                   	push   %ebp
80106103:	89 e5                	mov    %esp,%ebp
80106105:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106108:	e8 fe e1 ff ff       	call   8010430b <myproc>
8010610d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106110:	e8 fe d4 ff ff       	call   80103613 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106115:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106118:	89 44 24 04          	mov    %eax,0x4(%esp)
8010611c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106123:	e8 2c f4 ff ff       	call   80105554 <argstr>
80106128:	85 c0                	test   %eax,%eax
8010612a:	78 14                	js     80106140 <sys_chdir+0x3e>
8010612c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010612f:	89 04 24             	mov    %eax,(%esp)
80106132:	e8 08 c5 ff ff       	call   8010263f <namei>
80106137:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010613a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010613e:	75 0c                	jne    8010614c <sys_chdir+0x4a>
    end_op();
80106140:	e8 50 d5 ff ff       	call   80103695 <end_op>
    return -1;
80106145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614a:	eb 5a                	jmp    801061a6 <sys_chdir+0xa4>
  }
  ilock(ip);
8010614c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010614f:	89 04 24             	mov    %eax,(%esp)
80106152:	e8 c3 b9 ff ff       	call   80101b1a <ilock>
  if(ip->type != T_DIR){
80106157:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010615a:	8b 40 50             	mov    0x50(%eax),%eax
8010615d:	66 83 f8 01          	cmp    $0x1,%ax
80106161:	74 17                	je     8010617a <sys_chdir+0x78>
    iunlockput(ip);
80106163:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106166:	89 04 24             	mov    %eax,(%esp)
80106169:	e8 ab bb ff ff       	call   80101d19 <iunlockput>
    end_op();
8010616e:	e8 22 d5 ff ff       	call   80103695 <end_op>
    return -1;
80106173:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106178:	eb 2c                	jmp    801061a6 <sys_chdir+0xa4>
  }
  iunlock(ip);
8010617a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617d:	89 04 24             	mov    %eax,(%esp)
80106180:	e8 9f ba ff ff       	call   80101c24 <iunlock>
  iput(curproc->cwd);
80106185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106188:	8b 40 68             	mov    0x68(%eax),%eax
8010618b:	89 04 24             	mov    %eax,(%esp)
8010618e:	e8 d5 ba ff ff       	call   80101c68 <iput>
  end_op();
80106193:	e8 fd d4 ff ff       	call   80103695 <end_op>
  curproc->cwd = ip;
80106198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010619e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801061a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061a6:	c9                   	leave  
801061a7:	c3                   	ret    

801061a8 <sys_exec>:

int
sys_exec(void)
{
801061a8:	55                   	push   %ebp
801061a9:	89 e5                	mov    %esp,%ebp
801061ab:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801061b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801061b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061bf:	e8 90 f3 ff ff       	call   80105554 <argstr>
801061c4:	85 c0                	test   %eax,%eax
801061c6:	78 1a                	js     801061e2 <sys_exec+0x3a>
801061c8:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801061ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801061d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801061d9:	e8 df f2 ff ff       	call   801054bd <argint>
801061de:	85 c0                	test   %eax,%eax
801061e0:	79 0a                	jns    801061ec <sys_exec+0x44>
    return -1;
801061e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e7:	e9 c7 00 00 00       	jmp    801062b3 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
801061ec:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801061f3:	00 
801061f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801061fb:	00 
801061fc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106202:	89 04 24             	mov    %eax,(%esp)
80106205:	e8 80 ef ff ff       	call   8010518a <memset>
  for(i=0;; i++){
8010620a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106214:	83 f8 1f             	cmp    $0x1f,%eax
80106217:	76 0a                	jbe    80106223 <sys_exec+0x7b>
      return -1;
80106219:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621e:	e9 90 00 00 00       	jmp    801062b3 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106226:	c1 e0 02             	shl    $0x2,%eax
80106229:	89 c2                	mov    %eax,%edx
8010622b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106231:	01 c2                	add    %eax,%edx
80106233:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106239:	89 44 24 04          	mov    %eax,0x4(%esp)
8010623d:	89 14 24             	mov    %edx,(%esp)
80106240:	e8 d7 f1 ff ff       	call   8010541c <fetchint>
80106245:	85 c0                	test   %eax,%eax
80106247:	79 07                	jns    80106250 <sys_exec+0xa8>
      return -1;
80106249:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624e:	eb 63                	jmp    801062b3 <sys_exec+0x10b>
    if(uarg == 0){
80106250:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106256:	85 c0                	test   %eax,%eax
80106258:	75 26                	jne    80106280 <sys_exec+0xd8>
      argv[i] = 0;
8010625a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106264:	00 00 00 00 
      break;
80106268:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106269:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106272:	89 54 24 04          	mov    %edx,0x4(%esp)
80106276:	89 04 24             	mov    %eax,(%esp)
80106279:	e8 aa a9 ff ff       	call   80100c28 <exec>
8010627e:	eb 33                	jmp    801062b3 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106280:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106286:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106289:	c1 e2 02             	shl    $0x2,%edx
8010628c:	01 c2                	add    %eax,%edx
8010628e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106294:	89 54 24 04          	mov    %edx,0x4(%esp)
80106298:	89 04 24             	mov    %eax,(%esp)
8010629b:	e8 bb f1 ff ff       	call   8010545b <fetchstr>
801062a0:	85 c0                	test   %eax,%eax
801062a2:	79 07                	jns    801062ab <sys_exec+0x103>
      return -1;
801062a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a9:	eb 08                	jmp    801062b3 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801062ab:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801062ae:	e9 5e ff ff ff       	jmp    80106211 <sys_exec+0x69>
  return exec(path, argv);
}
801062b3:	c9                   	leave  
801062b4:	c3                   	ret    

801062b5 <sys_pipe>:

int
sys_pipe(void)
{
801062b5:	55                   	push   %ebp
801062b6:	89 e5                	mov    %esp,%ebp
801062b8:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801062bb:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801062c2:	00 
801062c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801062ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062d1:	e8 14 f2 ff ff       	call   801054ea <argptr>
801062d6:	85 c0                	test   %eax,%eax
801062d8:	79 0a                	jns    801062e4 <sys_pipe+0x2f>
    return -1;
801062da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062df:	e9 9a 00 00 00       	jmp    8010637e <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
801062e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801062eb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062ee:	89 04 24             	mov    %eax,(%esp)
801062f1:	e8 6a db ff ff       	call   80103e60 <pipealloc>
801062f6:	85 c0                	test   %eax,%eax
801062f8:	79 07                	jns    80106301 <sys_pipe+0x4c>
    return -1;
801062fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ff:	eb 7d                	jmp    8010637e <sys_pipe+0xc9>
  fd0 = -1;
80106301:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106308:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010630b:	89 04 24             	mov    %eax,(%esp)
8010630e:	e8 75 f3 ff ff       	call   80105688 <fdalloc>
80106313:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106316:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010631a:	78 14                	js     80106330 <sys_pipe+0x7b>
8010631c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010631f:	89 04 24             	mov    %eax,(%esp)
80106322:	e8 61 f3 ff ff       	call   80105688 <fdalloc>
80106327:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010632a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010632e:	79 36                	jns    80106366 <sys_pipe+0xb1>
    if(fd0 >= 0)
80106330:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106334:	78 13                	js     80106349 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106336:	e8 d0 df ff ff       	call   8010430b <myproc>
8010633b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010633e:	83 c2 08             	add    $0x8,%edx
80106341:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106348:	00 
    fileclose(rf);
80106349:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010634c:	89 04 24             	mov    %eax,(%esp)
8010634f:	e8 3e ae ff ff       	call   80101192 <fileclose>
    fileclose(wf);
80106354:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106357:	89 04 24             	mov    %eax,(%esp)
8010635a:	e8 33 ae ff ff       	call   80101192 <fileclose>
    return -1;
8010635f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106364:	eb 18                	jmp    8010637e <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106366:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106369:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010636c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010636e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106371:	8d 50 04             	lea    0x4(%eax),%edx
80106374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106377:	89 02                	mov    %eax,(%edx)
  return 0;
80106379:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010637e:	c9                   	leave  
8010637f:	c3                   	ret    

80106380 <sys_fork>:
#include "proc.h"
#include "container.h"

int
sys_fork(void)
{
80106380:	55                   	push   %ebp
80106381:	89 e5                	mov    %esp,%ebp
80106383:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106386:	e8 89 e2 ff ff       	call   80104614 <fork>
}
8010638b:	c9                   	leave  
8010638c:	c3                   	ret    

8010638d <sys_exit>:

int
sys_exit(void)
{
8010638d:	55                   	push   %ebp
8010638e:	89 e5                	mov    %esp,%ebp
80106390:	83 ec 08             	sub    $0x8,%esp
  exit();
80106393:	e8 e2 e3 ff ff       	call   8010477a <exit>
  return 0;  // not reached
80106398:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010639d:	c9                   	leave  
8010639e:	c3                   	ret    

8010639f <sys_wait>:

int
sys_wait(void)
{
8010639f:	55                   	push   %ebp
801063a0:	89 e5                	mov    %esp,%ebp
801063a2:	83 ec 08             	sub    $0x8,%esp
  return wait();
801063a5:	e8 d9 e4 ff ff       	call   80104883 <wait>
}
801063aa:	c9                   	leave  
801063ab:	c3                   	ret    

801063ac <sys_kill>:

int
sys_kill(void)
{
801063ac:	55                   	push   %ebp
801063ad:	89 e5                	mov    %esp,%ebp
801063af:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801063b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801063b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063c0:	e8 f8 f0 ff ff       	call   801054bd <argint>
801063c5:	85 c0                	test   %eax,%eax
801063c7:	79 07                	jns    801063d0 <sys_kill+0x24>
    return -1;
801063c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ce:	eb 0b                	jmp    801063db <sys_kill+0x2f>
  return kill(pid);
801063d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d3:	89 04 24             	mov    %eax,(%esp)
801063d6:	e8 7d e8 ff ff       	call   80104c58 <kill>
}
801063db:	c9                   	leave  
801063dc:	c3                   	ret    

801063dd <sys_getpid>:

int
sys_getpid(void)
{
801063dd:	55                   	push   %ebp
801063de:	89 e5                	mov    %esp,%ebp
801063e0:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801063e3:	e8 23 df ff ff       	call   8010430b <myproc>
801063e8:	8b 40 10             	mov    0x10(%eax),%eax
}
801063eb:	c9                   	leave  
801063ec:	c3                   	ret    

801063ed <sys_sbrk>:

int
sys_sbrk(void)
{
801063ed:	55                   	push   %ebp
801063ee:	89 e5                	mov    %esp,%ebp
801063f0:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801063f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801063fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106401:	e8 b7 f0 ff ff       	call   801054bd <argint>
80106406:	85 c0                	test   %eax,%eax
80106408:	79 07                	jns    80106411 <sys_sbrk+0x24>
    return -1;
8010640a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640f:	eb 23                	jmp    80106434 <sys_sbrk+0x47>
  addr = myproc()->sz;
80106411:	e8 f5 de ff ff       	call   8010430b <myproc>
80106416:	8b 00                	mov    (%eax),%eax
80106418:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010641b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641e:	89 04 24             	mov    %eax,(%esp)
80106421:	e8 50 e1 ff ff       	call   80104576 <growproc>
80106426:	85 c0                	test   %eax,%eax
80106428:	79 07                	jns    80106431 <sys_sbrk+0x44>
    return -1;
8010642a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642f:	eb 03                	jmp    80106434 <sys_sbrk+0x47>
  return addr;
80106431:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106434:	c9                   	leave  
80106435:	c3                   	ret    

80106436 <sys_sleep>:

int
sys_sleep(void)
{
80106436:	55                   	push   %ebp
80106437:	89 e5                	mov    %esp,%ebp
80106439:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010643c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010643f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106443:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010644a:	e8 6e f0 ff ff       	call   801054bd <argint>
8010644f:	85 c0                	test   %eax,%eax
80106451:	79 07                	jns    8010645a <sys_sleep+0x24>
    return -1;
80106453:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106458:	eb 6b                	jmp    801064c5 <sys_sleep+0x8f>
  acquire(&tickslock);
8010645a:	c7 04 24 20 72 11 80 	movl   $0x80117220,(%esp)
80106461:	e8 c1 ea ff ff       	call   80104f27 <acquire>
  ticks0 = ticks;
80106466:	a1 60 7a 11 80       	mov    0x80117a60,%eax
8010646b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010646e:	eb 33                	jmp    801064a3 <sys_sleep+0x6d>
    if(myproc()->killed){
80106470:	e8 96 de ff ff       	call   8010430b <myproc>
80106475:	8b 40 24             	mov    0x24(%eax),%eax
80106478:	85 c0                	test   %eax,%eax
8010647a:	74 13                	je     8010648f <sys_sleep+0x59>
      release(&tickslock);
8010647c:	c7 04 24 20 72 11 80 	movl   $0x80117220,(%esp)
80106483:	e8 09 eb ff ff       	call   80104f91 <release>
      return -1;
80106488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648d:	eb 36                	jmp    801064c5 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
8010648f:	c7 44 24 04 20 72 11 	movl   $0x80117220,0x4(%esp)
80106496:	80 
80106497:	c7 04 24 60 7a 11 80 	movl   $0x80117a60,(%esp)
8010649e:	e8 b6 e6 ff ff       	call   80104b59 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801064a3:	a1 60 7a 11 80       	mov    0x80117a60,%eax
801064a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801064ab:	89 c2                	mov    %eax,%edx
801064ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b0:	39 c2                	cmp    %eax,%edx
801064b2:	72 bc                	jb     80106470 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801064b4:	c7 04 24 20 72 11 80 	movl   $0x80117220,(%esp)
801064bb:	e8 d1 ea ff ff       	call   80104f91 <release>
  return 0;
801064c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064c5:	c9                   	leave  
801064c6:	c3                   	ret    

801064c7 <sys_container_init>:

void sys_container_init(){
801064c7:	55                   	push   %ebp
801064c8:	89 e5                	mov    %esp,%ebp
801064ca:	83 ec 08             	sub    $0x8,%esp
  container_init();
801064cd:	e8 28 25 00 00       	call   801089fa <container_init>
}
801064d2:	c9                   	leave  
801064d3:	c3                   	ret    

801064d4 <sys_is_full>:

int sys_is_full(void){
801064d4:	55                   	push   %ebp
801064d5:	89 e5                	mov    %esp,%ebp
801064d7:	83 ec 08             	sub    $0x8,%esp
  return is_full();
801064da:	e8 0c 22 00 00       	call   801086eb <is_full>
}
801064df:	c9                   	leave  
801064e0:	c3                   	ret    

801064e1 <sys_find>:

int sys_find(void){
801064e1:	55                   	push   %ebp
801064e2:	89 e5                	mov    %esp,%ebp
801064e4:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
801064e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064f5:	e8 5a f0 ff ff       	call   80105554 <argstr>

  return find(name);
801064fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fd:	89 04 24             	mov    %eax,(%esp)
80106500:	e8 31 22 00 00       	call   80108736 <find>
}
80106505:	c9                   	leave  
80106506:	c3                   	ret    

80106507 <sys_get_name>:

void sys_get_name(void){
80106507:	55                   	push   %ebp
80106508:	89 e5                	mov    %esp,%ebp
8010650a:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0, &name);
8010650d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106510:	89 44 24 04          	mov    %eax,0x4(%esp)
80106514:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010651b:	e8 34 f0 ff ff       	call   80105554 <argstr>

  int vc_num;
  argint(1, &vc_num);
80106520:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106523:	89 44 24 04          	mov    %eax,0x4(%esp)
80106527:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010652e:	e8 8a ef ff ff       	call   801054bd <argint>

  get_name(name, vc_num);
80106533:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106539:	89 54 24 04          	mov    %edx,0x4(%esp)
8010653d:	89 04 24             	mov    %eax,(%esp)
80106540:	e8 59 21 00 00       	call   8010869e <get_name>
  return;
80106545:	90                   	nop
}
80106546:	c9                   	leave  
80106547:	c3                   	ret    

80106548 <sys_get_max_proc>:

int sys_get_max_proc(void){
80106548:	55                   	push   %ebp
80106549:	89 e5                	mov    %esp,%ebp
8010654b:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010654e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106551:	89 44 24 04          	mov    %eax,0x4(%esp)
80106555:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010655c:	e8 5c ef ff ff       	call   801054bd <argint>


  return get_max_proc(vc_num);  
80106561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106564:	89 04 24             	mov    %eax,(%esp)
80106567:	e8 1c 22 00 00       	call   80108788 <get_max_proc>
}
8010656c:	c9                   	leave  
8010656d:	c3                   	ret    

8010656e <sys_get_max_mem>:

int sys_get_max_mem(void){
8010656e:	55                   	push   %ebp
8010656f:	89 e5                	mov    %esp,%ebp
80106571:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106574:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106577:	89 44 24 04          	mov    %eax,0x4(%esp)
8010657b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106582:	e8 36 ef ff ff       	call   801054bd <argint>


  return get_max_mem(vc_num);
80106587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658a:	89 04 24             	mov    %eax,(%esp)
8010658d:	e8 31 22 00 00       	call   801087c3 <get_max_mem>
}
80106592:	c9                   	leave  
80106593:	c3                   	ret    

80106594 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106594:	55                   	push   %ebp
80106595:	89 e5                	mov    %esp,%ebp
80106597:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010659a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010659d:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065a8:	e8 10 ef ff ff       	call   801054bd <argint>


  return get_max_disk(vc_num);
801065ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b0:	89 04 24             	mov    %eax,(%esp)
801065b3:	e8 46 22 00 00       	call   801087fe <get_max_disk>

}
801065b8:	c9                   	leave  
801065b9:	c3                   	ret    

801065ba <sys_get_curr_proc>:

int sys_get_curr_proc(void){
801065ba:	55                   	push   %ebp
801065bb:	89 e5                	mov    %esp,%ebp
801065bd:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
801065c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801065c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065ce:	e8 ea ee ff ff       	call   801054bd <argint>


  return get_curr_proc(vc_num);
801065d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d6:	89 04 24             	mov    %eax,(%esp)
801065d9:	e8 5b 22 00 00       	call   80108839 <get_curr_proc>
}
801065de:	c9                   	leave  
801065df:	c3                   	ret    

801065e0 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
801065e0:	55                   	push   %ebp
801065e1:	89 e5                	mov    %esp,%ebp
801065e3:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
801065e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065f4:	e8 c4 ee ff ff       	call   801054bd <argint>


  return get_curr_mem(vc_num);
801065f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fc:	89 04 24             	mov    %eax,(%esp)
801065ff:	e8 70 22 00 00       	call   80108874 <get_curr_mem>
}
80106604:	c9                   	leave  
80106605:	c3                   	ret    

80106606 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106606:	55                   	push   %ebp
80106607:	89 e5                	mov    %esp,%ebp
80106609:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
8010660c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010660f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106613:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010661a:	e8 9e ee ff ff       	call   801054bd <argint>


  return get_curr_disk(vc_num);
8010661f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106622:	89 04 24             	mov    %eax,(%esp)
80106625:	e8 85 22 00 00       	call   801088af <get_curr_disk>
}
8010662a:	c9                   	leave  
8010662b:	c3                   	ret    

8010662c <sys_set_name>:

void sys_set_name(void){
8010662c:	55                   	push   %ebp
8010662d:	89 e5                	mov    %esp,%ebp
8010662f:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106632:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106635:	89 44 24 04          	mov    %eax,0x4(%esp)
80106639:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106640:	e8 0f ef ff ff       	call   80105554 <argstr>

  int vc_num;
  argint(1, &vc_num);
80106645:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106648:	89 44 24 04          	mov    %eax,0x4(%esp)
8010664c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106653:	e8 65 ee ff ff       	call   801054bd <argint>

  set_name(name, vc_num);
80106658:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010665b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106662:	89 04 24             	mov    %eax,(%esp)
80106665:	e8 80 22 00 00       	call   801088ea <set_name>
}
8010666a:	c9                   	leave  
8010666b:	c3                   	ret    

8010666c <sys_set_max_mem>:

void sys_set_max_mem(void){
8010666c:	55                   	push   %ebp
8010666d:	89 e5                	mov    %esp,%ebp
8010666f:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106672:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106675:	89 44 24 04          	mov    %eax,0x4(%esp)
80106679:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106680:	e8 38 ee ff ff       	call   801054bd <argint>

  int vc_num;
  argint(1, &vc_num);
80106685:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106688:	89 44 24 04          	mov    %eax,0x4(%esp)
8010668c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106693:	e8 25 ee ff ff       	call   801054bd <argint>

  set_max_mem(mem, vc_num);
80106698:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010669b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010669e:	89 54 24 04          	mov    %edx,0x4(%esp)
801066a2:	89 04 24             	mov    %eax,(%esp)
801066a5:	e8 72 22 00 00       	call   8010891c <set_max_mem>
}
801066aa:	c9                   	leave  
801066ab:	c3                   	ret    

801066ac <sys_set_max_disk>:

void sys_set_max_disk(void){
801066ac:	55                   	push   %ebp
801066ad:	89 e5                	mov    %esp,%ebp
801066af:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
801066b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801066b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066c0:	e8 f8 ed ff ff       	call   801054bd <argint>

  int vc_num;
  argint(1, &vc_num);
801066c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801066cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066d3:	e8 e5 ed ff ff       	call   801054bd <argint>

  set_max_disk(disk, vc_num);
801066d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801066db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066de:	89 54 24 04          	mov    %edx,0x4(%esp)
801066e2:	89 04 24             	mov    %eax,(%esp)
801066e5:	e8 52 22 00 00       	call   8010893c <set_max_disk>
}
801066ea:	c9                   	leave  
801066eb:	c3                   	ret    

801066ec <sys_set_max_proc>:

void sys_set_max_proc(void){
801066ec:	55                   	push   %ebp
801066ed:	89 e5                	mov    %esp,%ebp
801066ef:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
801066f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801066f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106700:	e8 b8 ed ff ff       	call   801054bd <argint>

  int vc_num;
  argint(1, &vc_num);
80106705:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106708:	89 44 24 04          	mov    %eax,0x4(%esp)
8010670c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106713:	e8 a5 ed ff ff       	call   801054bd <argint>

  set_max_proc(proc, vc_num);
80106718:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010671b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010671e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106722:	89 04 24             	mov    %eax,(%esp)
80106725:	e8 33 22 00 00       	call   8010895d <set_max_proc>
}
8010672a:	c9                   	leave  
8010672b:	c3                   	ret    

8010672c <sys_set_curr_mem>:

void sys_set_curr_mem(void){
8010672c:	55                   	push   %ebp
8010672d:	89 e5                	mov    %esp,%ebp
8010672f:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106732:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106735:	89 44 24 04          	mov    %eax,0x4(%esp)
80106739:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106740:	e8 78 ed ff ff       	call   801054bd <argint>

  int vc_num;
  argint(1, &vc_num);
80106745:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106748:	89 44 24 04          	mov    %eax,0x4(%esp)
8010674c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106753:	e8 65 ed ff ff       	call   801054bd <argint>

  set_curr_mem(mem, vc_num);
80106758:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010675b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106762:	89 04 24             	mov    %eax,(%esp)
80106765:	e8 14 22 00 00       	call   8010897e <set_curr_mem>
}
8010676a:	c9                   	leave  
8010676b:	c3                   	ret    

8010676c <sys_set_curr_disk>:

void sys_set_curr_disk(void){
8010676c:	55                   	push   %ebp
8010676d:	89 e5                	mov    %esp,%ebp
8010676f:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106772:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106775:	89 44 24 04          	mov    %eax,0x4(%esp)
80106779:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106780:	e8 38 ed ff ff       	call   801054bd <argint>

  int vc_num;
  argint(1, &vc_num);
80106785:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106788:	89 44 24 04          	mov    %eax,0x4(%esp)
8010678c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106793:	e8 25 ed ff ff       	call   801054bd <argint>

  set_curr_disk(disk, vc_num);
80106798:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010679b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679e:	89 54 24 04          	mov    %edx,0x4(%esp)
801067a2:	89 04 24             	mov    %eax,(%esp)
801067a5:	e8 f5 21 00 00       	call   8010899f <set_curr_disk>
}
801067aa:	c9                   	leave  
801067ab:	c3                   	ret    

801067ac <sys_set_curr_proc>:

void sys_set_curr_proc(void){
801067ac:	55                   	push   %ebp
801067ad:	89 e5                	mov    %esp,%ebp
801067af:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
801067b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801067b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067c0:	e8 f8 ec ff ff       	call   801054bd <argint>

  int vc_num;
  argint(1, &vc_num);
801067c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801067cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801067d3:	e8 e5 ec ff ff       	call   801054bd <argint>

  set_curr_proc(proc, vc_num);
801067d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801067db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067de:	89 54 24 04          	mov    %edx,0x4(%esp)
801067e2:	89 04 24             	mov    %eax,(%esp)
801067e5:	e8 f0 21 00 00       	call   801089da <set_curr_proc>
}
801067ea:	c9                   	leave  
801067eb:	c3                   	ret    

801067ec <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801067ec:	55                   	push   %ebp
801067ed:	89 e5                	mov    %esp,%ebp
801067ef:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
801067f2:	c7 04 24 20 72 11 80 	movl   $0x80117220,(%esp)
801067f9:	e8 29 e7 ff ff       	call   80104f27 <acquire>
  xticks = ticks;
801067fe:	a1 60 7a 11 80       	mov    0x80117a60,%eax
80106803:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106806:	c7 04 24 20 72 11 80 	movl   $0x80117220,(%esp)
8010680d:	e8 7f e7 ff ff       	call   80104f91 <release>
  return xticks;
80106812:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106815:	c9                   	leave  
80106816:	c3                   	ret    

80106817 <sys_getticks>:

int
sys_getticks(void)
{
80106817:	55                   	push   %ebp
80106818:	89 e5                	mov    %esp,%ebp
8010681a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
8010681d:	e8 e9 da ff ff       	call   8010430b <myproc>
80106822:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106825:	c9                   	leave  
80106826:	c3                   	ret    
	...

80106828 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106828:	1e                   	push   %ds
  pushl %es
80106829:	06                   	push   %es
  pushl %fs
8010682a:	0f a0                	push   %fs
  pushl %gs
8010682c:	0f a8                	push   %gs
  pushal
8010682e:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010682f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106833:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106835:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106837:	54                   	push   %esp
  call trap
80106838:	e8 c0 01 00 00       	call   801069fd <trap>
  addl $4, %esp
8010683d:	83 c4 04             	add    $0x4,%esp

80106840 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106840:	61                   	popa   
  popl %gs
80106841:	0f a9                	pop    %gs
  popl %fs
80106843:	0f a1                	pop    %fs
  popl %es
80106845:	07                   	pop    %es
  popl %ds
80106846:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106847:	83 c4 08             	add    $0x8,%esp
  iret
8010684a:	cf                   	iret   
	...

8010684c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010684c:	55                   	push   %ebp
8010684d:	89 e5                	mov    %esp,%ebp
8010684f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106852:	8b 45 0c             	mov    0xc(%ebp),%eax
80106855:	48                   	dec    %eax
80106856:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010685a:	8b 45 08             	mov    0x8(%ebp),%eax
8010685d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106861:	8b 45 08             	mov    0x8(%ebp),%eax
80106864:	c1 e8 10             	shr    $0x10,%eax
80106867:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010686b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010686e:	0f 01 18             	lidtl  (%eax)
}
80106871:	c9                   	leave  
80106872:	c3                   	ret    

80106873 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106873:	55                   	push   %ebp
80106874:	89 e5                	mov    %esp,%ebp
80106876:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106879:	0f 20 d0             	mov    %cr2,%eax
8010687c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010687f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106882:	c9                   	leave  
80106883:	c3                   	ret    

80106884 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106884:	55                   	push   %ebp
80106885:	89 e5                	mov    %esp,%ebp
80106887:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010688a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106891:	e9 b8 00 00 00       	jmp    8010694e <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106899:	8b 04 85 c0 c0 10 80 	mov    -0x7fef3f40(,%eax,4),%eax
801068a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801068a3:	66 89 04 d5 60 72 11 	mov    %ax,-0x7fee8da0(,%edx,8)
801068aa:	80 
801068ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ae:	66 c7 04 c5 62 72 11 	movw   $0x8,-0x7fee8d9e(,%eax,8)
801068b5:	80 08 00 
801068b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068bb:	8a 14 c5 64 72 11 80 	mov    -0x7fee8d9c(,%eax,8),%dl
801068c2:	83 e2 e0             	and    $0xffffffe0,%edx
801068c5:	88 14 c5 64 72 11 80 	mov    %dl,-0x7fee8d9c(,%eax,8)
801068cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068cf:	8a 14 c5 64 72 11 80 	mov    -0x7fee8d9c(,%eax,8),%dl
801068d6:	83 e2 1f             	and    $0x1f,%edx
801068d9:	88 14 c5 64 72 11 80 	mov    %dl,-0x7fee8d9c(,%eax,8)
801068e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e3:	8a 14 c5 65 72 11 80 	mov    -0x7fee8d9b(,%eax,8),%dl
801068ea:	83 e2 f0             	and    $0xfffffff0,%edx
801068ed:	83 ca 0e             	or     $0xe,%edx
801068f0:	88 14 c5 65 72 11 80 	mov    %dl,-0x7fee8d9b(,%eax,8)
801068f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fa:	8a 14 c5 65 72 11 80 	mov    -0x7fee8d9b(,%eax,8),%dl
80106901:	83 e2 ef             	and    $0xffffffef,%edx
80106904:	88 14 c5 65 72 11 80 	mov    %dl,-0x7fee8d9b(,%eax,8)
8010690b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010690e:	8a 14 c5 65 72 11 80 	mov    -0x7fee8d9b(,%eax,8),%dl
80106915:	83 e2 9f             	and    $0xffffff9f,%edx
80106918:	88 14 c5 65 72 11 80 	mov    %dl,-0x7fee8d9b(,%eax,8)
8010691f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106922:	8a 14 c5 65 72 11 80 	mov    -0x7fee8d9b(,%eax,8),%dl
80106929:	83 ca 80             	or     $0xffffff80,%edx
8010692c:	88 14 c5 65 72 11 80 	mov    %dl,-0x7fee8d9b(,%eax,8)
80106933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106936:	8b 04 85 c0 c0 10 80 	mov    -0x7fef3f40(,%eax,4),%eax
8010693d:	c1 e8 10             	shr    $0x10,%eax
80106940:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106943:	66 89 04 d5 66 72 11 	mov    %ax,-0x7fee8d9a(,%edx,8)
8010694a:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010694b:	ff 45 f4             	incl   -0xc(%ebp)
8010694e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106955:	0f 8e 3b ff ff ff    	jle    80106896 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010695b:	a1 c0 c1 10 80       	mov    0x8010c1c0,%eax
80106960:	66 a3 60 74 11 80    	mov    %ax,0x80117460
80106966:	66 c7 05 62 74 11 80 	movw   $0x8,0x80117462
8010696d:	08 00 
8010696f:	a0 64 74 11 80       	mov    0x80117464,%al
80106974:	83 e0 e0             	and    $0xffffffe0,%eax
80106977:	a2 64 74 11 80       	mov    %al,0x80117464
8010697c:	a0 64 74 11 80       	mov    0x80117464,%al
80106981:	83 e0 1f             	and    $0x1f,%eax
80106984:	a2 64 74 11 80       	mov    %al,0x80117464
80106989:	a0 65 74 11 80       	mov    0x80117465,%al
8010698e:	83 c8 0f             	or     $0xf,%eax
80106991:	a2 65 74 11 80       	mov    %al,0x80117465
80106996:	a0 65 74 11 80       	mov    0x80117465,%al
8010699b:	83 e0 ef             	and    $0xffffffef,%eax
8010699e:	a2 65 74 11 80       	mov    %al,0x80117465
801069a3:	a0 65 74 11 80       	mov    0x80117465,%al
801069a8:	83 c8 60             	or     $0x60,%eax
801069ab:	a2 65 74 11 80       	mov    %al,0x80117465
801069b0:	a0 65 74 11 80       	mov    0x80117465,%al
801069b5:	83 c8 80             	or     $0xffffff80,%eax
801069b8:	a2 65 74 11 80       	mov    %al,0x80117465
801069bd:	a1 c0 c1 10 80       	mov    0x8010c1c0,%eax
801069c2:	c1 e8 10             	shr    $0x10,%eax
801069c5:	66 a3 66 74 11 80    	mov    %ax,0x80117466

  initlock(&tickslock, "time");
801069cb:	c7 44 24 04 fc 8f 10 	movl   $0x80108ffc,0x4(%esp)
801069d2:	80 
801069d3:	c7 04 24 20 72 11 80 	movl   $0x80117220,(%esp)
801069da:	e8 27 e5 ff ff       	call   80104f06 <initlock>
}
801069df:	c9                   	leave  
801069e0:	c3                   	ret    

801069e1 <idtinit>:

void
idtinit(void)
{
801069e1:	55                   	push   %ebp
801069e2:	89 e5                	mov    %esp,%ebp
801069e4:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801069e7:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801069ee:	00 
801069ef:	c7 04 24 60 72 11 80 	movl   $0x80117260,(%esp)
801069f6:	e8 51 fe ff ff       	call   8010684c <lidt>
}
801069fb:	c9                   	leave  
801069fc:	c3                   	ret    

801069fd <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801069fd:	55                   	push   %ebp
801069fe:	89 e5                	mov    %esp,%ebp
80106a00:	57                   	push   %edi
80106a01:	56                   	push   %esi
80106a02:	53                   	push   %ebx
80106a03:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80106a06:	8b 45 08             	mov    0x8(%ebp),%eax
80106a09:	8b 40 30             	mov    0x30(%eax),%eax
80106a0c:	83 f8 40             	cmp    $0x40,%eax
80106a0f:	75 3c                	jne    80106a4d <trap+0x50>
    if(myproc()->killed)
80106a11:	e8 f5 d8 ff ff       	call   8010430b <myproc>
80106a16:	8b 40 24             	mov    0x24(%eax),%eax
80106a19:	85 c0                	test   %eax,%eax
80106a1b:	74 05                	je     80106a22 <trap+0x25>
      exit();
80106a1d:	e8 58 dd ff ff       	call   8010477a <exit>
    myproc()->tf = tf;
80106a22:	e8 e4 d8 ff ff       	call   8010430b <myproc>
80106a27:	8b 55 08             	mov    0x8(%ebp),%edx
80106a2a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106a2d:	e8 59 eb ff ff       	call   8010558b <syscall>
    if(myproc()->killed)
80106a32:	e8 d4 d8 ff ff       	call   8010430b <myproc>
80106a37:	8b 40 24             	mov    0x24(%eax),%eax
80106a3a:	85 c0                	test   %eax,%eax
80106a3c:	74 0a                	je     80106a48 <trap+0x4b>
      exit();
80106a3e:	e8 37 dd ff ff       	call   8010477a <exit>
    return;
80106a43:	e9 30 02 00 00       	jmp    80106c78 <trap+0x27b>
80106a48:	e9 2b 02 00 00       	jmp    80106c78 <trap+0x27b>
  }

  switch(tf->trapno){
80106a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a50:	8b 40 30             	mov    0x30(%eax),%eax
80106a53:	83 e8 20             	sub    $0x20,%eax
80106a56:	83 f8 1f             	cmp    $0x1f,%eax
80106a59:	0f 87 cb 00 00 00    	ja     80106b2a <trap+0x12d>
80106a5f:	8b 04 85 a4 90 10 80 	mov    -0x7fef6f5c(,%eax,4),%eax
80106a66:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106a68:	e8 d5 d7 ff ff       	call   80104242 <cpuid>
80106a6d:	85 c0                	test   %eax,%eax
80106a6f:	75 2f                	jne    80106aa0 <trap+0xa3>
      acquire(&tickslock);
80106a71:	c7 04 24 20 72 11 80 	movl   $0x80117220,(%esp)
80106a78:	e8 aa e4 ff ff       	call   80104f27 <acquire>
      ticks++;
80106a7d:	a1 60 7a 11 80       	mov    0x80117a60,%eax
80106a82:	40                   	inc    %eax
80106a83:	a3 60 7a 11 80       	mov    %eax,0x80117a60
      wakeup(&ticks);
80106a88:	c7 04 24 60 7a 11 80 	movl   $0x80117a60,(%esp)
80106a8f:	e8 99 e1 ff ff       	call   80104c2d <wakeup>
      release(&tickslock);
80106a94:	c7 04 24 20 72 11 80 	movl   $0x80117220,(%esp)
80106a9b:	e8 f1 e4 ff ff       	call   80104f91 <release>
    }
    p = myproc();
80106aa0:	e8 66 d8 ff ff       	call   8010430b <myproc>
80106aa5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80106aa8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106aac:	74 0f                	je     80106abd <trap+0xc0>
      p->ticks++;
80106aae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ab1:	8b 40 7c             	mov    0x7c(%eax),%eax
80106ab4:	8d 50 01             	lea    0x1(%eax),%edx
80106ab7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106aba:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80106abd:	e8 29 c6 ff ff       	call   801030eb <lapiceoi>
    break;
80106ac2:	e9 35 01 00 00       	jmp    80106bfc <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106ac7:	e8 9e be ff ff       	call   8010296a <ideintr>
    lapiceoi();
80106acc:	e8 1a c6 ff ff       	call   801030eb <lapiceoi>
    break;
80106ad1:	e9 26 01 00 00       	jmp    80106bfc <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106ad6:	e8 27 c4 ff ff       	call   80102f02 <kbdintr>
    lapiceoi();
80106adb:	e8 0b c6 ff ff       	call   801030eb <lapiceoi>
    break;
80106ae0:	e9 17 01 00 00       	jmp    80106bfc <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106ae5:	e8 6f 03 00 00       	call   80106e59 <uartintr>
    lapiceoi();
80106aea:	e8 fc c5 ff ff       	call   801030eb <lapiceoi>
    break;
80106aef:	e9 08 01 00 00       	jmp    80106bfc <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106af4:	8b 45 08             	mov    0x8(%ebp),%eax
80106af7:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106afa:	8b 45 08             	mov    0x8(%ebp),%eax
80106afd:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b00:	0f b7 d8             	movzwl %ax,%ebx
80106b03:	e8 3a d7 ff ff       	call   80104242 <cpuid>
80106b08:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106b0c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80106b10:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b14:	c7 04 24 04 90 10 80 	movl   $0x80109004,(%esp)
80106b1b:	e8 a1 98 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80106b20:	e8 c6 c5 ff ff       	call   801030eb <lapiceoi>
    break;
80106b25:	e9 d2 00 00 00       	jmp    80106bfc <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106b2a:	e8 dc d7 ff ff       	call   8010430b <myproc>
80106b2f:	85 c0                	test   %eax,%eax
80106b31:	74 10                	je     80106b43 <trap+0x146>
80106b33:	8b 45 08             	mov    0x8(%ebp),%eax
80106b36:	8b 40 3c             	mov    0x3c(%eax),%eax
80106b39:	0f b7 c0             	movzwl %ax,%eax
80106b3c:	83 e0 03             	and    $0x3,%eax
80106b3f:	85 c0                	test   %eax,%eax
80106b41:	75 40                	jne    80106b83 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b43:	e8 2b fd ff ff       	call   80106873 <rcr2>
80106b48:	89 c3                	mov    %eax,%ebx
80106b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4d:	8b 70 38             	mov    0x38(%eax),%esi
80106b50:	e8 ed d6 ff ff       	call   80104242 <cpuid>
80106b55:	8b 55 08             	mov    0x8(%ebp),%edx
80106b58:	8b 52 30             	mov    0x30(%edx),%edx
80106b5b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b5f:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106b63:	89 44 24 08          	mov    %eax,0x8(%esp)
80106b67:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b6b:	c7 04 24 28 90 10 80 	movl   $0x80109028,(%esp)
80106b72:	e8 4a 98 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106b77:	c7 04 24 5a 90 10 80 	movl   $0x8010905a,(%esp)
80106b7e:	e8 d1 99 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b83:	e8 eb fc ff ff       	call   80106873 <rcr2>
80106b88:	89 c6                	mov    %eax,%esi
80106b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8d:	8b 40 38             	mov    0x38(%eax),%eax
80106b90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106b93:	e8 aa d6 ff ff       	call   80104242 <cpuid>
80106b98:	89 c3                	mov    %eax,%ebx
80106b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b9d:	8b 78 34             	mov    0x34(%eax),%edi
80106ba0:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba6:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106ba9:	e8 5d d7 ff ff       	call   8010430b <myproc>
80106bae:	8d 50 6c             	lea    0x6c(%eax),%edx
80106bb1:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106bb4:	e8 52 d7 ff ff       	call   8010430b <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106bb9:	8b 40 10             	mov    0x10(%eax),%eax
80106bbc:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80106bc0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80106bc3:	89 4c 24 18          	mov    %ecx,0x18(%esp)
80106bc7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80106bcb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80106bce:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80106bd2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80106bd6:	8b 55 cc             	mov    -0x34(%ebp),%edx
80106bd9:	89 54 24 08          	mov    %edx,0x8(%esp)
80106bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106be1:	c7 04 24 60 90 10 80 	movl   $0x80109060,(%esp)
80106be8:	e8 d4 97 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106bed:	e8 19 d7 ff ff       	call   8010430b <myproc>
80106bf2:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106bf9:	eb 01                	jmp    80106bfc <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106bfb:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106bfc:	e8 0a d7 ff ff       	call   8010430b <myproc>
80106c01:	85 c0                	test   %eax,%eax
80106c03:	74 22                	je     80106c27 <trap+0x22a>
80106c05:	e8 01 d7 ff ff       	call   8010430b <myproc>
80106c0a:	8b 40 24             	mov    0x24(%eax),%eax
80106c0d:	85 c0                	test   %eax,%eax
80106c0f:	74 16                	je     80106c27 <trap+0x22a>
80106c11:	8b 45 08             	mov    0x8(%ebp),%eax
80106c14:	8b 40 3c             	mov    0x3c(%eax),%eax
80106c17:	0f b7 c0             	movzwl %ax,%eax
80106c1a:	83 e0 03             	and    $0x3,%eax
80106c1d:	83 f8 03             	cmp    $0x3,%eax
80106c20:	75 05                	jne    80106c27 <trap+0x22a>
    exit();
80106c22:	e8 53 db ff ff       	call   8010477a <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106c27:	e8 df d6 ff ff       	call   8010430b <myproc>
80106c2c:	85 c0                	test   %eax,%eax
80106c2e:	74 1d                	je     80106c4d <trap+0x250>
80106c30:	e8 d6 d6 ff ff       	call   8010430b <myproc>
80106c35:	8b 40 0c             	mov    0xc(%eax),%eax
80106c38:	83 f8 04             	cmp    $0x4,%eax
80106c3b:	75 10                	jne    80106c4d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80106c40:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106c43:	83 f8 20             	cmp    $0x20,%eax
80106c46:	75 05                	jne    80106c4d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106c48:	e8 9c de ff ff       	call   80104ae9 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106c4d:	e8 b9 d6 ff ff       	call   8010430b <myproc>
80106c52:	85 c0                	test   %eax,%eax
80106c54:	74 22                	je     80106c78 <trap+0x27b>
80106c56:	e8 b0 d6 ff ff       	call   8010430b <myproc>
80106c5b:	8b 40 24             	mov    0x24(%eax),%eax
80106c5e:	85 c0                	test   %eax,%eax
80106c60:	74 16                	je     80106c78 <trap+0x27b>
80106c62:	8b 45 08             	mov    0x8(%ebp),%eax
80106c65:	8b 40 3c             	mov    0x3c(%eax),%eax
80106c68:	0f b7 c0             	movzwl %ax,%eax
80106c6b:	83 e0 03             	and    $0x3,%eax
80106c6e:	83 f8 03             	cmp    $0x3,%eax
80106c71:	75 05                	jne    80106c78 <trap+0x27b>
    exit();
80106c73:	e8 02 db ff ff       	call   8010477a <exit>
}
80106c78:	83 c4 4c             	add    $0x4c,%esp
80106c7b:	5b                   	pop    %ebx
80106c7c:	5e                   	pop    %esi
80106c7d:	5f                   	pop    %edi
80106c7e:	5d                   	pop    %ebp
80106c7f:	c3                   	ret    

80106c80 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106c80:	55                   	push   %ebp
80106c81:	89 e5                	mov    %esp,%ebp
80106c83:	83 ec 14             	sub    $0x14,%esp
80106c86:	8b 45 08             	mov    0x8(%ebp),%eax
80106c89:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106c90:	89 c2                	mov    %eax,%edx
80106c92:	ec                   	in     (%dx),%al
80106c93:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106c96:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80106c99:	c9                   	leave  
80106c9a:	c3                   	ret    

80106c9b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c9b:	55                   	push   %ebp
80106c9c:	89 e5                	mov    %esp,%ebp
80106c9e:	83 ec 08             	sub    $0x8,%esp
80106ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca4:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ca7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106cab:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106cae:	8a 45 f8             	mov    -0x8(%ebp),%al
80106cb1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106cb4:	ee                   	out    %al,(%dx)
}
80106cb5:	c9                   	leave  
80106cb6:	c3                   	ret    

80106cb7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106cb7:	55                   	push   %ebp
80106cb8:	89 e5                	mov    %esp,%ebp
80106cba:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106cbd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cc4:	00 
80106cc5:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106ccc:	e8 ca ff ff ff       	call   80106c9b <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106cd1:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106cd8:	00 
80106cd9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106ce0:	e8 b6 ff ff ff       	call   80106c9b <outb>
  outb(COM1+0, 115200/9600);
80106ce5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106cec:	00 
80106ced:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cf4:	e8 a2 ff ff ff       	call   80106c9b <outb>
  outb(COM1+1, 0);
80106cf9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d00:	00 
80106d01:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106d08:	e8 8e ff ff ff       	call   80106c9b <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106d0d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106d14:	00 
80106d15:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106d1c:	e8 7a ff ff ff       	call   80106c9b <outb>
  outb(COM1+4, 0);
80106d21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d28:	00 
80106d29:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106d30:	e8 66 ff ff ff       	call   80106c9b <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106d35:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106d3c:	00 
80106d3d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106d44:	e8 52 ff ff ff       	call   80106c9b <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d49:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d50:	e8 2b ff ff ff       	call   80106c80 <inb>
80106d55:	3c ff                	cmp    $0xff,%al
80106d57:	75 02                	jne    80106d5b <uartinit+0xa4>
    return;
80106d59:	eb 5b                	jmp    80106db6 <uartinit+0xff>
  uart = 1;
80106d5b:	c7 05 c4 c8 10 80 01 	movl   $0x1,0x8010c8c4
80106d62:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106d65:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106d6c:	e8 0f ff ff ff       	call   80106c80 <inb>
  inb(COM1+0);
80106d71:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d78:	e8 03 ff ff ff       	call   80106c80 <inb>
  ioapicenable(IRQ_COM1, 0);
80106d7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d84:	00 
80106d85:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d8c:	e8 4e be ff ff       	call   80102bdf <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d91:	c7 45 f4 24 91 10 80 	movl   $0x80109124,-0xc(%ebp)
80106d98:	eb 13                	jmp    80106dad <uartinit+0xf6>
    uartputc(*p);
80106d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d9d:	8a 00                	mov    (%eax),%al
80106d9f:	0f be c0             	movsbl %al,%eax
80106da2:	89 04 24             	mov    %eax,(%esp)
80106da5:	e8 0e 00 00 00       	call   80106db8 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106daa:	ff 45 f4             	incl   -0xc(%ebp)
80106dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106db0:	8a 00                	mov    (%eax),%al
80106db2:	84 c0                	test   %al,%al
80106db4:	75 e4                	jne    80106d9a <uartinit+0xe3>
    uartputc(*p);
}
80106db6:	c9                   	leave  
80106db7:	c3                   	ret    

80106db8 <uartputc>:

void
uartputc(int c)
{
80106db8:	55                   	push   %ebp
80106db9:	89 e5                	mov    %esp,%ebp
80106dbb:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106dbe:	a1 c4 c8 10 80       	mov    0x8010c8c4,%eax
80106dc3:	85 c0                	test   %eax,%eax
80106dc5:	75 02                	jne    80106dc9 <uartputc+0x11>
    return;
80106dc7:	eb 4a                	jmp    80106e13 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106dc9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106dd0:	eb 0f                	jmp    80106de1 <uartputc+0x29>
    microdelay(10);
80106dd2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106dd9:	e8 32 c3 ff ff       	call   80103110 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106dde:	ff 45 f4             	incl   -0xc(%ebp)
80106de1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106de5:	7f 16                	jg     80106dfd <uartputc+0x45>
80106de7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dee:	e8 8d fe ff ff       	call   80106c80 <inb>
80106df3:	0f b6 c0             	movzbl %al,%eax
80106df6:	83 e0 20             	and    $0x20,%eax
80106df9:	85 c0                	test   %eax,%eax
80106dfb:	74 d5                	je     80106dd2 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80106e00:	0f b6 c0             	movzbl %al,%eax
80106e03:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e07:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e0e:	e8 88 fe ff ff       	call   80106c9b <outb>
}
80106e13:	c9                   	leave  
80106e14:	c3                   	ret    

80106e15 <uartgetc>:

static int
uartgetc(void)
{
80106e15:	55                   	push   %ebp
80106e16:	89 e5                	mov    %esp,%ebp
80106e18:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106e1b:	a1 c4 c8 10 80       	mov    0x8010c8c4,%eax
80106e20:	85 c0                	test   %eax,%eax
80106e22:	75 07                	jne    80106e2b <uartgetc+0x16>
    return -1;
80106e24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e29:	eb 2c                	jmp    80106e57 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106e2b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e32:	e8 49 fe ff ff       	call   80106c80 <inb>
80106e37:	0f b6 c0             	movzbl %al,%eax
80106e3a:	83 e0 01             	and    $0x1,%eax
80106e3d:	85 c0                	test   %eax,%eax
80106e3f:	75 07                	jne    80106e48 <uartgetc+0x33>
    return -1;
80106e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e46:	eb 0f                	jmp    80106e57 <uartgetc+0x42>
  return inb(COM1+0);
80106e48:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e4f:	e8 2c fe ff ff       	call   80106c80 <inb>
80106e54:	0f b6 c0             	movzbl %al,%eax
}
80106e57:	c9                   	leave  
80106e58:	c3                   	ret    

80106e59 <uartintr>:

void
uartintr(void)
{
80106e59:	55                   	push   %ebp
80106e5a:	89 e5                	mov    %esp,%ebp
80106e5c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106e5f:	c7 04 24 15 6e 10 80 	movl   $0x80106e15,(%esp)
80106e66:	e8 8a 99 ff ff       	call   801007f5 <consoleintr>
}
80106e6b:	c9                   	leave  
80106e6c:	c3                   	ret    
80106e6d:	00 00                	add    %al,(%eax)
	...

80106e70 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $0
80106e72:	6a 00                	push   $0x0
  jmp alltraps
80106e74:	e9 af f9 ff ff       	jmp    80106828 <alltraps>

80106e79 <vector1>:
.globl vector1
vector1:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $1
80106e7b:	6a 01                	push   $0x1
  jmp alltraps
80106e7d:	e9 a6 f9 ff ff       	jmp    80106828 <alltraps>

80106e82 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $2
80106e84:	6a 02                	push   $0x2
  jmp alltraps
80106e86:	e9 9d f9 ff ff       	jmp    80106828 <alltraps>

80106e8b <vector3>:
.globl vector3
vector3:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $3
80106e8d:	6a 03                	push   $0x3
  jmp alltraps
80106e8f:	e9 94 f9 ff ff       	jmp    80106828 <alltraps>

80106e94 <vector4>:
.globl vector4
vector4:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $4
80106e96:	6a 04                	push   $0x4
  jmp alltraps
80106e98:	e9 8b f9 ff ff       	jmp    80106828 <alltraps>

80106e9d <vector5>:
.globl vector5
vector5:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $5
80106e9f:	6a 05                	push   $0x5
  jmp alltraps
80106ea1:	e9 82 f9 ff ff       	jmp    80106828 <alltraps>

80106ea6 <vector6>:
.globl vector6
vector6:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $6
80106ea8:	6a 06                	push   $0x6
  jmp alltraps
80106eaa:	e9 79 f9 ff ff       	jmp    80106828 <alltraps>

80106eaf <vector7>:
.globl vector7
vector7:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $7
80106eb1:	6a 07                	push   $0x7
  jmp alltraps
80106eb3:	e9 70 f9 ff ff       	jmp    80106828 <alltraps>

80106eb8 <vector8>:
.globl vector8
vector8:
  pushl $8
80106eb8:	6a 08                	push   $0x8
  jmp alltraps
80106eba:	e9 69 f9 ff ff       	jmp    80106828 <alltraps>

80106ebf <vector9>:
.globl vector9
vector9:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $9
80106ec1:	6a 09                	push   $0x9
  jmp alltraps
80106ec3:	e9 60 f9 ff ff       	jmp    80106828 <alltraps>

80106ec8 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ec8:	6a 0a                	push   $0xa
  jmp alltraps
80106eca:	e9 59 f9 ff ff       	jmp    80106828 <alltraps>

80106ecf <vector11>:
.globl vector11
vector11:
  pushl $11
80106ecf:	6a 0b                	push   $0xb
  jmp alltraps
80106ed1:	e9 52 f9 ff ff       	jmp    80106828 <alltraps>

80106ed6 <vector12>:
.globl vector12
vector12:
  pushl $12
80106ed6:	6a 0c                	push   $0xc
  jmp alltraps
80106ed8:	e9 4b f9 ff ff       	jmp    80106828 <alltraps>

80106edd <vector13>:
.globl vector13
vector13:
  pushl $13
80106edd:	6a 0d                	push   $0xd
  jmp alltraps
80106edf:	e9 44 f9 ff ff       	jmp    80106828 <alltraps>

80106ee4 <vector14>:
.globl vector14
vector14:
  pushl $14
80106ee4:	6a 0e                	push   $0xe
  jmp alltraps
80106ee6:	e9 3d f9 ff ff       	jmp    80106828 <alltraps>

80106eeb <vector15>:
.globl vector15
vector15:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $15
80106eed:	6a 0f                	push   $0xf
  jmp alltraps
80106eef:	e9 34 f9 ff ff       	jmp    80106828 <alltraps>

80106ef4 <vector16>:
.globl vector16
vector16:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $16
80106ef6:	6a 10                	push   $0x10
  jmp alltraps
80106ef8:	e9 2b f9 ff ff       	jmp    80106828 <alltraps>

80106efd <vector17>:
.globl vector17
vector17:
  pushl $17
80106efd:	6a 11                	push   $0x11
  jmp alltraps
80106eff:	e9 24 f9 ff ff       	jmp    80106828 <alltraps>

80106f04 <vector18>:
.globl vector18
vector18:
  pushl $0
80106f04:	6a 00                	push   $0x0
  pushl $18
80106f06:	6a 12                	push   $0x12
  jmp alltraps
80106f08:	e9 1b f9 ff ff       	jmp    80106828 <alltraps>

80106f0d <vector19>:
.globl vector19
vector19:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $19
80106f0f:	6a 13                	push   $0x13
  jmp alltraps
80106f11:	e9 12 f9 ff ff       	jmp    80106828 <alltraps>

80106f16 <vector20>:
.globl vector20
vector20:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $20
80106f18:	6a 14                	push   $0x14
  jmp alltraps
80106f1a:	e9 09 f9 ff ff       	jmp    80106828 <alltraps>

80106f1f <vector21>:
.globl vector21
vector21:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $21
80106f21:	6a 15                	push   $0x15
  jmp alltraps
80106f23:	e9 00 f9 ff ff       	jmp    80106828 <alltraps>

80106f28 <vector22>:
.globl vector22
vector22:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $22
80106f2a:	6a 16                	push   $0x16
  jmp alltraps
80106f2c:	e9 f7 f8 ff ff       	jmp    80106828 <alltraps>

80106f31 <vector23>:
.globl vector23
vector23:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $23
80106f33:	6a 17                	push   $0x17
  jmp alltraps
80106f35:	e9 ee f8 ff ff       	jmp    80106828 <alltraps>

80106f3a <vector24>:
.globl vector24
vector24:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $24
80106f3c:	6a 18                	push   $0x18
  jmp alltraps
80106f3e:	e9 e5 f8 ff ff       	jmp    80106828 <alltraps>

80106f43 <vector25>:
.globl vector25
vector25:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $25
80106f45:	6a 19                	push   $0x19
  jmp alltraps
80106f47:	e9 dc f8 ff ff       	jmp    80106828 <alltraps>

80106f4c <vector26>:
.globl vector26
vector26:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $26
80106f4e:	6a 1a                	push   $0x1a
  jmp alltraps
80106f50:	e9 d3 f8 ff ff       	jmp    80106828 <alltraps>

80106f55 <vector27>:
.globl vector27
vector27:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $27
80106f57:	6a 1b                	push   $0x1b
  jmp alltraps
80106f59:	e9 ca f8 ff ff       	jmp    80106828 <alltraps>

80106f5e <vector28>:
.globl vector28
vector28:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $28
80106f60:	6a 1c                	push   $0x1c
  jmp alltraps
80106f62:	e9 c1 f8 ff ff       	jmp    80106828 <alltraps>

80106f67 <vector29>:
.globl vector29
vector29:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $29
80106f69:	6a 1d                	push   $0x1d
  jmp alltraps
80106f6b:	e9 b8 f8 ff ff       	jmp    80106828 <alltraps>

80106f70 <vector30>:
.globl vector30
vector30:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $30
80106f72:	6a 1e                	push   $0x1e
  jmp alltraps
80106f74:	e9 af f8 ff ff       	jmp    80106828 <alltraps>

80106f79 <vector31>:
.globl vector31
vector31:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $31
80106f7b:	6a 1f                	push   $0x1f
  jmp alltraps
80106f7d:	e9 a6 f8 ff ff       	jmp    80106828 <alltraps>

80106f82 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f82:	6a 00                	push   $0x0
  pushl $32
80106f84:	6a 20                	push   $0x20
  jmp alltraps
80106f86:	e9 9d f8 ff ff       	jmp    80106828 <alltraps>

80106f8b <vector33>:
.globl vector33
vector33:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $33
80106f8d:	6a 21                	push   $0x21
  jmp alltraps
80106f8f:	e9 94 f8 ff ff       	jmp    80106828 <alltraps>

80106f94 <vector34>:
.globl vector34
vector34:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $34
80106f96:	6a 22                	push   $0x22
  jmp alltraps
80106f98:	e9 8b f8 ff ff       	jmp    80106828 <alltraps>

80106f9d <vector35>:
.globl vector35
vector35:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $35
80106f9f:	6a 23                	push   $0x23
  jmp alltraps
80106fa1:	e9 82 f8 ff ff       	jmp    80106828 <alltraps>

80106fa6 <vector36>:
.globl vector36
vector36:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $36
80106fa8:	6a 24                	push   $0x24
  jmp alltraps
80106faa:	e9 79 f8 ff ff       	jmp    80106828 <alltraps>

80106faf <vector37>:
.globl vector37
vector37:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $37
80106fb1:	6a 25                	push   $0x25
  jmp alltraps
80106fb3:	e9 70 f8 ff ff       	jmp    80106828 <alltraps>

80106fb8 <vector38>:
.globl vector38
vector38:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $38
80106fba:	6a 26                	push   $0x26
  jmp alltraps
80106fbc:	e9 67 f8 ff ff       	jmp    80106828 <alltraps>

80106fc1 <vector39>:
.globl vector39
vector39:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $39
80106fc3:	6a 27                	push   $0x27
  jmp alltraps
80106fc5:	e9 5e f8 ff ff       	jmp    80106828 <alltraps>

80106fca <vector40>:
.globl vector40
vector40:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $40
80106fcc:	6a 28                	push   $0x28
  jmp alltraps
80106fce:	e9 55 f8 ff ff       	jmp    80106828 <alltraps>

80106fd3 <vector41>:
.globl vector41
vector41:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $41
80106fd5:	6a 29                	push   $0x29
  jmp alltraps
80106fd7:	e9 4c f8 ff ff       	jmp    80106828 <alltraps>

80106fdc <vector42>:
.globl vector42
vector42:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $42
80106fde:	6a 2a                	push   $0x2a
  jmp alltraps
80106fe0:	e9 43 f8 ff ff       	jmp    80106828 <alltraps>

80106fe5 <vector43>:
.globl vector43
vector43:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $43
80106fe7:	6a 2b                	push   $0x2b
  jmp alltraps
80106fe9:	e9 3a f8 ff ff       	jmp    80106828 <alltraps>

80106fee <vector44>:
.globl vector44
vector44:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $44
80106ff0:	6a 2c                	push   $0x2c
  jmp alltraps
80106ff2:	e9 31 f8 ff ff       	jmp    80106828 <alltraps>

80106ff7 <vector45>:
.globl vector45
vector45:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $45
80106ff9:	6a 2d                	push   $0x2d
  jmp alltraps
80106ffb:	e9 28 f8 ff ff       	jmp    80106828 <alltraps>

80107000 <vector46>:
.globl vector46
vector46:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $46
80107002:	6a 2e                	push   $0x2e
  jmp alltraps
80107004:	e9 1f f8 ff ff       	jmp    80106828 <alltraps>

80107009 <vector47>:
.globl vector47
vector47:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $47
8010700b:	6a 2f                	push   $0x2f
  jmp alltraps
8010700d:	e9 16 f8 ff ff       	jmp    80106828 <alltraps>

80107012 <vector48>:
.globl vector48
vector48:
  pushl $0
80107012:	6a 00                	push   $0x0
  pushl $48
80107014:	6a 30                	push   $0x30
  jmp alltraps
80107016:	e9 0d f8 ff ff       	jmp    80106828 <alltraps>

8010701b <vector49>:
.globl vector49
vector49:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $49
8010701d:	6a 31                	push   $0x31
  jmp alltraps
8010701f:	e9 04 f8 ff ff       	jmp    80106828 <alltraps>

80107024 <vector50>:
.globl vector50
vector50:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $50
80107026:	6a 32                	push   $0x32
  jmp alltraps
80107028:	e9 fb f7 ff ff       	jmp    80106828 <alltraps>

8010702d <vector51>:
.globl vector51
vector51:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $51
8010702f:	6a 33                	push   $0x33
  jmp alltraps
80107031:	e9 f2 f7 ff ff       	jmp    80106828 <alltraps>

80107036 <vector52>:
.globl vector52
vector52:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $52
80107038:	6a 34                	push   $0x34
  jmp alltraps
8010703a:	e9 e9 f7 ff ff       	jmp    80106828 <alltraps>

8010703f <vector53>:
.globl vector53
vector53:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $53
80107041:	6a 35                	push   $0x35
  jmp alltraps
80107043:	e9 e0 f7 ff ff       	jmp    80106828 <alltraps>

80107048 <vector54>:
.globl vector54
vector54:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $54
8010704a:	6a 36                	push   $0x36
  jmp alltraps
8010704c:	e9 d7 f7 ff ff       	jmp    80106828 <alltraps>

80107051 <vector55>:
.globl vector55
vector55:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $55
80107053:	6a 37                	push   $0x37
  jmp alltraps
80107055:	e9 ce f7 ff ff       	jmp    80106828 <alltraps>

8010705a <vector56>:
.globl vector56
vector56:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $56
8010705c:	6a 38                	push   $0x38
  jmp alltraps
8010705e:	e9 c5 f7 ff ff       	jmp    80106828 <alltraps>

80107063 <vector57>:
.globl vector57
vector57:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $57
80107065:	6a 39                	push   $0x39
  jmp alltraps
80107067:	e9 bc f7 ff ff       	jmp    80106828 <alltraps>

8010706c <vector58>:
.globl vector58
vector58:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $58
8010706e:	6a 3a                	push   $0x3a
  jmp alltraps
80107070:	e9 b3 f7 ff ff       	jmp    80106828 <alltraps>

80107075 <vector59>:
.globl vector59
vector59:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $59
80107077:	6a 3b                	push   $0x3b
  jmp alltraps
80107079:	e9 aa f7 ff ff       	jmp    80106828 <alltraps>

8010707e <vector60>:
.globl vector60
vector60:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $60
80107080:	6a 3c                	push   $0x3c
  jmp alltraps
80107082:	e9 a1 f7 ff ff       	jmp    80106828 <alltraps>

80107087 <vector61>:
.globl vector61
vector61:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $61
80107089:	6a 3d                	push   $0x3d
  jmp alltraps
8010708b:	e9 98 f7 ff ff       	jmp    80106828 <alltraps>

80107090 <vector62>:
.globl vector62
vector62:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $62
80107092:	6a 3e                	push   $0x3e
  jmp alltraps
80107094:	e9 8f f7 ff ff       	jmp    80106828 <alltraps>

80107099 <vector63>:
.globl vector63
vector63:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $63
8010709b:	6a 3f                	push   $0x3f
  jmp alltraps
8010709d:	e9 86 f7 ff ff       	jmp    80106828 <alltraps>

801070a2 <vector64>:
.globl vector64
vector64:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $64
801070a4:	6a 40                	push   $0x40
  jmp alltraps
801070a6:	e9 7d f7 ff ff       	jmp    80106828 <alltraps>

801070ab <vector65>:
.globl vector65
vector65:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $65
801070ad:	6a 41                	push   $0x41
  jmp alltraps
801070af:	e9 74 f7 ff ff       	jmp    80106828 <alltraps>

801070b4 <vector66>:
.globl vector66
vector66:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $66
801070b6:	6a 42                	push   $0x42
  jmp alltraps
801070b8:	e9 6b f7 ff ff       	jmp    80106828 <alltraps>

801070bd <vector67>:
.globl vector67
vector67:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $67
801070bf:	6a 43                	push   $0x43
  jmp alltraps
801070c1:	e9 62 f7 ff ff       	jmp    80106828 <alltraps>

801070c6 <vector68>:
.globl vector68
vector68:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $68
801070c8:	6a 44                	push   $0x44
  jmp alltraps
801070ca:	e9 59 f7 ff ff       	jmp    80106828 <alltraps>

801070cf <vector69>:
.globl vector69
vector69:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $69
801070d1:	6a 45                	push   $0x45
  jmp alltraps
801070d3:	e9 50 f7 ff ff       	jmp    80106828 <alltraps>

801070d8 <vector70>:
.globl vector70
vector70:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $70
801070da:	6a 46                	push   $0x46
  jmp alltraps
801070dc:	e9 47 f7 ff ff       	jmp    80106828 <alltraps>

801070e1 <vector71>:
.globl vector71
vector71:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $71
801070e3:	6a 47                	push   $0x47
  jmp alltraps
801070e5:	e9 3e f7 ff ff       	jmp    80106828 <alltraps>

801070ea <vector72>:
.globl vector72
vector72:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $72
801070ec:	6a 48                	push   $0x48
  jmp alltraps
801070ee:	e9 35 f7 ff ff       	jmp    80106828 <alltraps>

801070f3 <vector73>:
.globl vector73
vector73:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $73
801070f5:	6a 49                	push   $0x49
  jmp alltraps
801070f7:	e9 2c f7 ff ff       	jmp    80106828 <alltraps>

801070fc <vector74>:
.globl vector74
vector74:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $74
801070fe:	6a 4a                	push   $0x4a
  jmp alltraps
80107100:	e9 23 f7 ff ff       	jmp    80106828 <alltraps>

80107105 <vector75>:
.globl vector75
vector75:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $75
80107107:	6a 4b                	push   $0x4b
  jmp alltraps
80107109:	e9 1a f7 ff ff       	jmp    80106828 <alltraps>

8010710e <vector76>:
.globl vector76
vector76:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $76
80107110:	6a 4c                	push   $0x4c
  jmp alltraps
80107112:	e9 11 f7 ff ff       	jmp    80106828 <alltraps>

80107117 <vector77>:
.globl vector77
vector77:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $77
80107119:	6a 4d                	push   $0x4d
  jmp alltraps
8010711b:	e9 08 f7 ff ff       	jmp    80106828 <alltraps>

80107120 <vector78>:
.globl vector78
vector78:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $78
80107122:	6a 4e                	push   $0x4e
  jmp alltraps
80107124:	e9 ff f6 ff ff       	jmp    80106828 <alltraps>

80107129 <vector79>:
.globl vector79
vector79:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $79
8010712b:	6a 4f                	push   $0x4f
  jmp alltraps
8010712d:	e9 f6 f6 ff ff       	jmp    80106828 <alltraps>

80107132 <vector80>:
.globl vector80
vector80:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $80
80107134:	6a 50                	push   $0x50
  jmp alltraps
80107136:	e9 ed f6 ff ff       	jmp    80106828 <alltraps>

8010713b <vector81>:
.globl vector81
vector81:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $81
8010713d:	6a 51                	push   $0x51
  jmp alltraps
8010713f:	e9 e4 f6 ff ff       	jmp    80106828 <alltraps>

80107144 <vector82>:
.globl vector82
vector82:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $82
80107146:	6a 52                	push   $0x52
  jmp alltraps
80107148:	e9 db f6 ff ff       	jmp    80106828 <alltraps>

8010714d <vector83>:
.globl vector83
vector83:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $83
8010714f:	6a 53                	push   $0x53
  jmp alltraps
80107151:	e9 d2 f6 ff ff       	jmp    80106828 <alltraps>

80107156 <vector84>:
.globl vector84
vector84:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $84
80107158:	6a 54                	push   $0x54
  jmp alltraps
8010715a:	e9 c9 f6 ff ff       	jmp    80106828 <alltraps>

8010715f <vector85>:
.globl vector85
vector85:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $85
80107161:	6a 55                	push   $0x55
  jmp alltraps
80107163:	e9 c0 f6 ff ff       	jmp    80106828 <alltraps>

80107168 <vector86>:
.globl vector86
vector86:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $86
8010716a:	6a 56                	push   $0x56
  jmp alltraps
8010716c:	e9 b7 f6 ff ff       	jmp    80106828 <alltraps>

80107171 <vector87>:
.globl vector87
vector87:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $87
80107173:	6a 57                	push   $0x57
  jmp alltraps
80107175:	e9 ae f6 ff ff       	jmp    80106828 <alltraps>

8010717a <vector88>:
.globl vector88
vector88:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $88
8010717c:	6a 58                	push   $0x58
  jmp alltraps
8010717e:	e9 a5 f6 ff ff       	jmp    80106828 <alltraps>

80107183 <vector89>:
.globl vector89
vector89:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $89
80107185:	6a 59                	push   $0x59
  jmp alltraps
80107187:	e9 9c f6 ff ff       	jmp    80106828 <alltraps>

8010718c <vector90>:
.globl vector90
vector90:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $90
8010718e:	6a 5a                	push   $0x5a
  jmp alltraps
80107190:	e9 93 f6 ff ff       	jmp    80106828 <alltraps>

80107195 <vector91>:
.globl vector91
vector91:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $91
80107197:	6a 5b                	push   $0x5b
  jmp alltraps
80107199:	e9 8a f6 ff ff       	jmp    80106828 <alltraps>

8010719e <vector92>:
.globl vector92
vector92:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $92
801071a0:	6a 5c                	push   $0x5c
  jmp alltraps
801071a2:	e9 81 f6 ff ff       	jmp    80106828 <alltraps>

801071a7 <vector93>:
.globl vector93
vector93:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $93
801071a9:	6a 5d                	push   $0x5d
  jmp alltraps
801071ab:	e9 78 f6 ff ff       	jmp    80106828 <alltraps>

801071b0 <vector94>:
.globl vector94
vector94:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $94
801071b2:	6a 5e                	push   $0x5e
  jmp alltraps
801071b4:	e9 6f f6 ff ff       	jmp    80106828 <alltraps>

801071b9 <vector95>:
.globl vector95
vector95:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $95
801071bb:	6a 5f                	push   $0x5f
  jmp alltraps
801071bd:	e9 66 f6 ff ff       	jmp    80106828 <alltraps>

801071c2 <vector96>:
.globl vector96
vector96:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $96
801071c4:	6a 60                	push   $0x60
  jmp alltraps
801071c6:	e9 5d f6 ff ff       	jmp    80106828 <alltraps>

801071cb <vector97>:
.globl vector97
vector97:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $97
801071cd:	6a 61                	push   $0x61
  jmp alltraps
801071cf:	e9 54 f6 ff ff       	jmp    80106828 <alltraps>

801071d4 <vector98>:
.globl vector98
vector98:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $98
801071d6:	6a 62                	push   $0x62
  jmp alltraps
801071d8:	e9 4b f6 ff ff       	jmp    80106828 <alltraps>

801071dd <vector99>:
.globl vector99
vector99:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $99
801071df:	6a 63                	push   $0x63
  jmp alltraps
801071e1:	e9 42 f6 ff ff       	jmp    80106828 <alltraps>

801071e6 <vector100>:
.globl vector100
vector100:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $100
801071e8:	6a 64                	push   $0x64
  jmp alltraps
801071ea:	e9 39 f6 ff ff       	jmp    80106828 <alltraps>

801071ef <vector101>:
.globl vector101
vector101:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $101
801071f1:	6a 65                	push   $0x65
  jmp alltraps
801071f3:	e9 30 f6 ff ff       	jmp    80106828 <alltraps>

801071f8 <vector102>:
.globl vector102
vector102:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $102
801071fa:	6a 66                	push   $0x66
  jmp alltraps
801071fc:	e9 27 f6 ff ff       	jmp    80106828 <alltraps>

80107201 <vector103>:
.globl vector103
vector103:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $103
80107203:	6a 67                	push   $0x67
  jmp alltraps
80107205:	e9 1e f6 ff ff       	jmp    80106828 <alltraps>

8010720a <vector104>:
.globl vector104
vector104:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $104
8010720c:	6a 68                	push   $0x68
  jmp alltraps
8010720e:	e9 15 f6 ff ff       	jmp    80106828 <alltraps>

80107213 <vector105>:
.globl vector105
vector105:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $105
80107215:	6a 69                	push   $0x69
  jmp alltraps
80107217:	e9 0c f6 ff ff       	jmp    80106828 <alltraps>

8010721c <vector106>:
.globl vector106
vector106:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $106
8010721e:	6a 6a                	push   $0x6a
  jmp alltraps
80107220:	e9 03 f6 ff ff       	jmp    80106828 <alltraps>

80107225 <vector107>:
.globl vector107
vector107:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $107
80107227:	6a 6b                	push   $0x6b
  jmp alltraps
80107229:	e9 fa f5 ff ff       	jmp    80106828 <alltraps>

8010722e <vector108>:
.globl vector108
vector108:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $108
80107230:	6a 6c                	push   $0x6c
  jmp alltraps
80107232:	e9 f1 f5 ff ff       	jmp    80106828 <alltraps>

80107237 <vector109>:
.globl vector109
vector109:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $109
80107239:	6a 6d                	push   $0x6d
  jmp alltraps
8010723b:	e9 e8 f5 ff ff       	jmp    80106828 <alltraps>

80107240 <vector110>:
.globl vector110
vector110:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $110
80107242:	6a 6e                	push   $0x6e
  jmp alltraps
80107244:	e9 df f5 ff ff       	jmp    80106828 <alltraps>

80107249 <vector111>:
.globl vector111
vector111:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $111
8010724b:	6a 6f                	push   $0x6f
  jmp alltraps
8010724d:	e9 d6 f5 ff ff       	jmp    80106828 <alltraps>

80107252 <vector112>:
.globl vector112
vector112:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $112
80107254:	6a 70                	push   $0x70
  jmp alltraps
80107256:	e9 cd f5 ff ff       	jmp    80106828 <alltraps>

8010725b <vector113>:
.globl vector113
vector113:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $113
8010725d:	6a 71                	push   $0x71
  jmp alltraps
8010725f:	e9 c4 f5 ff ff       	jmp    80106828 <alltraps>

80107264 <vector114>:
.globl vector114
vector114:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $114
80107266:	6a 72                	push   $0x72
  jmp alltraps
80107268:	e9 bb f5 ff ff       	jmp    80106828 <alltraps>

8010726d <vector115>:
.globl vector115
vector115:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $115
8010726f:	6a 73                	push   $0x73
  jmp alltraps
80107271:	e9 b2 f5 ff ff       	jmp    80106828 <alltraps>

80107276 <vector116>:
.globl vector116
vector116:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $116
80107278:	6a 74                	push   $0x74
  jmp alltraps
8010727a:	e9 a9 f5 ff ff       	jmp    80106828 <alltraps>

8010727f <vector117>:
.globl vector117
vector117:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $117
80107281:	6a 75                	push   $0x75
  jmp alltraps
80107283:	e9 a0 f5 ff ff       	jmp    80106828 <alltraps>

80107288 <vector118>:
.globl vector118
vector118:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $118
8010728a:	6a 76                	push   $0x76
  jmp alltraps
8010728c:	e9 97 f5 ff ff       	jmp    80106828 <alltraps>

80107291 <vector119>:
.globl vector119
vector119:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $119
80107293:	6a 77                	push   $0x77
  jmp alltraps
80107295:	e9 8e f5 ff ff       	jmp    80106828 <alltraps>

8010729a <vector120>:
.globl vector120
vector120:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $120
8010729c:	6a 78                	push   $0x78
  jmp alltraps
8010729e:	e9 85 f5 ff ff       	jmp    80106828 <alltraps>

801072a3 <vector121>:
.globl vector121
vector121:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $121
801072a5:	6a 79                	push   $0x79
  jmp alltraps
801072a7:	e9 7c f5 ff ff       	jmp    80106828 <alltraps>

801072ac <vector122>:
.globl vector122
vector122:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $122
801072ae:	6a 7a                	push   $0x7a
  jmp alltraps
801072b0:	e9 73 f5 ff ff       	jmp    80106828 <alltraps>

801072b5 <vector123>:
.globl vector123
vector123:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $123
801072b7:	6a 7b                	push   $0x7b
  jmp alltraps
801072b9:	e9 6a f5 ff ff       	jmp    80106828 <alltraps>

801072be <vector124>:
.globl vector124
vector124:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $124
801072c0:	6a 7c                	push   $0x7c
  jmp alltraps
801072c2:	e9 61 f5 ff ff       	jmp    80106828 <alltraps>

801072c7 <vector125>:
.globl vector125
vector125:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $125
801072c9:	6a 7d                	push   $0x7d
  jmp alltraps
801072cb:	e9 58 f5 ff ff       	jmp    80106828 <alltraps>

801072d0 <vector126>:
.globl vector126
vector126:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $126
801072d2:	6a 7e                	push   $0x7e
  jmp alltraps
801072d4:	e9 4f f5 ff ff       	jmp    80106828 <alltraps>

801072d9 <vector127>:
.globl vector127
vector127:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $127
801072db:	6a 7f                	push   $0x7f
  jmp alltraps
801072dd:	e9 46 f5 ff ff       	jmp    80106828 <alltraps>

801072e2 <vector128>:
.globl vector128
vector128:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $128
801072e4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801072e9:	e9 3a f5 ff ff       	jmp    80106828 <alltraps>

801072ee <vector129>:
.globl vector129
vector129:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $129
801072f0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801072f5:	e9 2e f5 ff ff       	jmp    80106828 <alltraps>

801072fa <vector130>:
.globl vector130
vector130:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $130
801072fc:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107301:	e9 22 f5 ff ff       	jmp    80106828 <alltraps>

80107306 <vector131>:
.globl vector131
vector131:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $131
80107308:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010730d:	e9 16 f5 ff ff       	jmp    80106828 <alltraps>

80107312 <vector132>:
.globl vector132
vector132:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $132
80107314:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107319:	e9 0a f5 ff ff       	jmp    80106828 <alltraps>

8010731e <vector133>:
.globl vector133
vector133:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $133
80107320:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107325:	e9 fe f4 ff ff       	jmp    80106828 <alltraps>

8010732a <vector134>:
.globl vector134
vector134:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $134
8010732c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107331:	e9 f2 f4 ff ff       	jmp    80106828 <alltraps>

80107336 <vector135>:
.globl vector135
vector135:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $135
80107338:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010733d:	e9 e6 f4 ff ff       	jmp    80106828 <alltraps>

80107342 <vector136>:
.globl vector136
vector136:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $136
80107344:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107349:	e9 da f4 ff ff       	jmp    80106828 <alltraps>

8010734e <vector137>:
.globl vector137
vector137:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $137
80107350:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107355:	e9 ce f4 ff ff       	jmp    80106828 <alltraps>

8010735a <vector138>:
.globl vector138
vector138:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $138
8010735c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107361:	e9 c2 f4 ff ff       	jmp    80106828 <alltraps>

80107366 <vector139>:
.globl vector139
vector139:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $139
80107368:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010736d:	e9 b6 f4 ff ff       	jmp    80106828 <alltraps>

80107372 <vector140>:
.globl vector140
vector140:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $140
80107374:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107379:	e9 aa f4 ff ff       	jmp    80106828 <alltraps>

8010737e <vector141>:
.globl vector141
vector141:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $141
80107380:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107385:	e9 9e f4 ff ff       	jmp    80106828 <alltraps>

8010738a <vector142>:
.globl vector142
vector142:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $142
8010738c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107391:	e9 92 f4 ff ff       	jmp    80106828 <alltraps>

80107396 <vector143>:
.globl vector143
vector143:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $143
80107398:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010739d:	e9 86 f4 ff ff       	jmp    80106828 <alltraps>

801073a2 <vector144>:
.globl vector144
vector144:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $144
801073a4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801073a9:	e9 7a f4 ff ff       	jmp    80106828 <alltraps>

801073ae <vector145>:
.globl vector145
vector145:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $145
801073b0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801073b5:	e9 6e f4 ff ff       	jmp    80106828 <alltraps>

801073ba <vector146>:
.globl vector146
vector146:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $146
801073bc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801073c1:	e9 62 f4 ff ff       	jmp    80106828 <alltraps>

801073c6 <vector147>:
.globl vector147
vector147:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $147
801073c8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801073cd:	e9 56 f4 ff ff       	jmp    80106828 <alltraps>

801073d2 <vector148>:
.globl vector148
vector148:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $148
801073d4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801073d9:	e9 4a f4 ff ff       	jmp    80106828 <alltraps>

801073de <vector149>:
.globl vector149
vector149:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $149
801073e0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801073e5:	e9 3e f4 ff ff       	jmp    80106828 <alltraps>

801073ea <vector150>:
.globl vector150
vector150:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $150
801073ec:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801073f1:	e9 32 f4 ff ff       	jmp    80106828 <alltraps>

801073f6 <vector151>:
.globl vector151
vector151:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $151
801073f8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801073fd:	e9 26 f4 ff ff       	jmp    80106828 <alltraps>

80107402 <vector152>:
.globl vector152
vector152:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $152
80107404:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107409:	e9 1a f4 ff ff       	jmp    80106828 <alltraps>

8010740e <vector153>:
.globl vector153
vector153:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $153
80107410:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107415:	e9 0e f4 ff ff       	jmp    80106828 <alltraps>

8010741a <vector154>:
.globl vector154
vector154:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $154
8010741c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107421:	e9 02 f4 ff ff       	jmp    80106828 <alltraps>

80107426 <vector155>:
.globl vector155
vector155:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $155
80107428:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010742d:	e9 f6 f3 ff ff       	jmp    80106828 <alltraps>

80107432 <vector156>:
.globl vector156
vector156:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $156
80107434:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107439:	e9 ea f3 ff ff       	jmp    80106828 <alltraps>

8010743e <vector157>:
.globl vector157
vector157:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $157
80107440:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107445:	e9 de f3 ff ff       	jmp    80106828 <alltraps>

8010744a <vector158>:
.globl vector158
vector158:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $158
8010744c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107451:	e9 d2 f3 ff ff       	jmp    80106828 <alltraps>

80107456 <vector159>:
.globl vector159
vector159:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $159
80107458:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010745d:	e9 c6 f3 ff ff       	jmp    80106828 <alltraps>

80107462 <vector160>:
.globl vector160
vector160:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $160
80107464:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107469:	e9 ba f3 ff ff       	jmp    80106828 <alltraps>

8010746e <vector161>:
.globl vector161
vector161:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $161
80107470:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107475:	e9 ae f3 ff ff       	jmp    80106828 <alltraps>

8010747a <vector162>:
.globl vector162
vector162:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $162
8010747c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107481:	e9 a2 f3 ff ff       	jmp    80106828 <alltraps>

80107486 <vector163>:
.globl vector163
vector163:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $163
80107488:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010748d:	e9 96 f3 ff ff       	jmp    80106828 <alltraps>

80107492 <vector164>:
.globl vector164
vector164:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $164
80107494:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107499:	e9 8a f3 ff ff       	jmp    80106828 <alltraps>

8010749e <vector165>:
.globl vector165
vector165:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $165
801074a0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801074a5:	e9 7e f3 ff ff       	jmp    80106828 <alltraps>

801074aa <vector166>:
.globl vector166
vector166:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $166
801074ac:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801074b1:	e9 72 f3 ff ff       	jmp    80106828 <alltraps>

801074b6 <vector167>:
.globl vector167
vector167:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $167
801074b8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801074bd:	e9 66 f3 ff ff       	jmp    80106828 <alltraps>

801074c2 <vector168>:
.globl vector168
vector168:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $168
801074c4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801074c9:	e9 5a f3 ff ff       	jmp    80106828 <alltraps>

801074ce <vector169>:
.globl vector169
vector169:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $169
801074d0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801074d5:	e9 4e f3 ff ff       	jmp    80106828 <alltraps>

801074da <vector170>:
.globl vector170
vector170:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $170
801074dc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801074e1:	e9 42 f3 ff ff       	jmp    80106828 <alltraps>

801074e6 <vector171>:
.globl vector171
vector171:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $171
801074e8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801074ed:	e9 36 f3 ff ff       	jmp    80106828 <alltraps>

801074f2 <vector172>:
.globl vector172
vector172:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $172
801074f4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801074f9:	e9 2a f3 ff ff       	jmp    80106828 <alltraps>

801074fe <vector173>:
.globl vector173
vector173:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $173
80107500:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107505:	e9 1e f3 ff ff       	jmp    80106828 <alltraps>

8010750a <vector174>:
.globl vector174
vector174:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $174
8010750c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107511:	e9 12 f3 ff ff       	jmp    80106828 <alltraps>

80107516 <vector175>:
.globl vector175
vector175:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $175
80107518:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010751d:	e9 06 f3 ff ff       	jmp    80106828 <alltraps>

80107522 <vector176>:
.globl vector176
vector176:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $176
80107524:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107529:	e9 fa f2 ff ff       	jmp    80106828 <alltraps>

8010752e <vector177>:
.globl vector177
vector177:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $177
80107530:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107535:	e9 ee f2 ff ff       	jmp    80106828 <alltraps>

8010753a <vector178>:
.globl vector178
vector178:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $178
8010753c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107541:	e9 e2 f2 ff ff       	jmp    80106828 <alltraps>

80107546 <vector179>:
.globl vector179
vector179:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $179
80107548:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010754d:	e9 d6 f2 ff ff       	jmp    80106828 <alltraps>

80107552 <vector180>:
.globl vector180
vector180:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $180
80107554:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107559:	e9 ca f2 ff ff       	jmp    80106828 <alltraps>

8010755e <vector181>:
.globl vector181
vector181:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $181
80107560:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107565:	e9 be f2 ff ff       	jmp    80106828 <alltraps>

8010756a <vector182>:
.globl vector182
vector182:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $182
8010756c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107571:	e9 b2 f2 ff ff       	jmp    80106828 <alltraps>

80107576 <vector183>:
.globl vector183
vector183:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $183
80107578:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010757d:	e9 a6 f2 ff ff       	jmp    80106828 <alltraps>

80107582 <vector184>:
.globl vector184
vector184:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $184
80107584:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107589:	e9 9a f2 ff ff       	jmp    80106828 <alltraps>

8010758e <vector185>:
.globl vector185
vector185:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $185
80107590:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107595:	e9 8e f2 ff ff       	jmp    80106828 <alltraps>

8010759a <vector186>:
.globl vector186
vector186:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $186
8010759c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801075a1:	e9 82 f2 ff ff       	jmp    80106828 <alltraps>

801075a6 <vector187>:
.globl vector187
vector187:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $187
801075a8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801075ad:	e9 76 f2 ff ff       	jmp    80106828 <alltraps>

801075b2 <vector188>:
.globl vector188
vector188:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $188
801075b4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801075b9:	e9 6a f2 ff ff       	jmp    80106828 <alltraps>

801075be <vector189>:
.globl vector189
vector189:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $189
801075c0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801075c5:	e9 5e f2 ff ff       	jmp    80106828 <alltraps>

801075ca <vector190>:
.globl vector190
vector190:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $190
801075cc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801075d1:	e9 52 f2 ff ff       	jmp    80106828 <alltraps>

801075d6 <vector191>:
.globl vector191
vector191:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $191
801075d8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801075dd:	e9 46 f2 ff ff       	jmp    80106828 <alltraps>

801075e2 <vector192>:
.globl vector192
vector192:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $192
801075e4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801075e9:	e9 3a f2 ff ff       	jmp    80106828 <alltraps>

801075ee <vector193>:
.globl vector193
vector193:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $193
801075f0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801075f5:	e9 2e f2 ff ff       	jmp    80106828 <alltraps>

801075fa <vector194>:
.globl vector194
vector194:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $194
801075fc:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107601:	e9 22 f2 ff ff       	jmp    80106828 <alltraps>

80107606 <vector195>:
.globl vector195
vector195:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $195
80107608:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010760d:	e9 16 f2 ff ff       	jmp    80106828 <alltraps>

80107612 <vector196>:
.globl vector196
vector196:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $196
80107614:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107619:	e9 0a f2 ff ff       	jmp    80106828 <alltraps>

8010761e <vector197>:
.globl vector197
vector197:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $197
80107620:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107625:	e9 fe f1 ff ff       	jmp    80106828 <alltraps>

8010762a <vector198>:
.globl vector198
vector198:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $198
8010762c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107631:	e9 f2 f1 ff ff       	jmp    80106828 <alltraps>

80107636 <vector199>:
.globl vector199
vector199:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $199
80107638:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010763d:	e9 e6 f1 ff ff       	jmp    80106828 <alltraps>

80107642 <vector200>:
.globl vector200
vector200:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $200
80107644:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107649:	e9 da f1 ff ff       	jmp    80106828 <alltraps>

8010764e <vector201>:
.globl vector201
vector201:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $201
80107650:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107655:	e9 ce f1 ff ff       	jmp    80106828 <alltraps>

8010765a <vector202>:
.globl vector202
vector202:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $202
8010765c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107661:	e9 c2 f1 ff ff       	jmp    80106828 <alltraps>

80107666 <vector203>:
.globl vector203
vector203:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $203
80107668:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010766d:	e9 b6 f1 ff ff       	jmp    80106828 <alltraps>

80107672 <vector204>:
.globl vector204
vector204:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $204
80107674:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107679:	e9 aa f1 ff ff       	jmp    80106828 <alltraps>

8010767e <vector205>:
.globl vector205
vector205:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $205
80107680:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107685:	e9 9e f1 ff ff       	jmp    80106828 <alltraps>

8010768a <vector206>:
.globl vector206
vector206:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $206
8010768c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107691:	e9 92 f1 ff ff       	jmp    80106828 <alltraps>

80107696 <vector207>:
.globl vector207
vector207:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $207
80107698:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010769d:	e9 86 f1 ff ff       	jmp    80106828 <alltraps>

801076a2 <vector208>:
.globl vector208
vector208:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $208
801076a4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801076a9:	e9 7a f1 ff ff       	jmp    80106828 <alltraps>

801076ae <vector209>:
.globl vector209
vector209:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $209
801076b0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801076b5:	e9 6e f1 ff ff       	jmp    80106828 <alltraps>

801076ba <vector210>:
.globl vector210
vector210:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $210
801076bc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801076c1:	e9 62 f1 ff ff       	jmp    80106828 <alltraps>

801076c6 <vector211>:
.globl vector211
vector211:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $211
801076c8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801076cd:	e9 56 f1 ff ff       	jmp    80106828 <alltraps>

801076d2 <vector212>:
.globl vector212
vector212:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $212
801076d4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801076d9:	e9 4a f1 ff ff       	jmp    80106828 <alltraps>

801076de <vector213>:
.globl vector213
vector213:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $213
801076e0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801076e5:	e9 3e f1 ff ff       	jmp    80106828 <alltraps>

801076ea <vector214>:
.globl vector214
vector214:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $214
801076ec:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801076f1:	e9 32 f1 ff ff       	jmp    80106828 <alltraps>

801076f6 <vector215>:
.globl vector215
vector215:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $215
801076f8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801076fd:	e9 26 f1 ff ff       	jmp    80106828 <alltraps>

80107702 <vector216>:
.globl vector216
vector216:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $216
80107704:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107709:	e9 1a f1 ff ff       	jmp    80106828 <alltraps>

8010770e <vector217>:
.globl vector217
vector217:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $217
80107710:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107715:	e9 0e f1 ff ff       	jmp    80106828 <alltraps>

8010771a <vector218>:
.globl vector218
vector218:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $218
8010771c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107721:	e9 02 f1 ff ff       	jmp    80106828 <alltraps>

80107726 <vector219>:
.globl vector219
vector219:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $219
80107728:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010772d:	e9 f6 f0 ff ff       	jmp    80106828 <alltraps>

80107732 <vector220>:
.globl vector220
vector220:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $220
80107734:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107739:	e9 ea f0 ff ff       	jmp    80106828 <alltraps>

8010773e <vector221>:
.globl vector221
vector221:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $221
80107740:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107745:	e9 de f0 ff ff       	jmp    80106828 <alltraps>

8010774a <vector222>:
.globl vector222
vector222:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $222
8010774c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107751:	e9 d2 f0 ff ff       	jmp    80106828 <alltraps>

80107756 <vector223>:
.globl vector223
vector223:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $223
80107758:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010775d:	e9 c6 f0 ff ff       	jmp    80106828 <alltraps>

80107762 <vector224>:
.globl vector224
vector224:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $224
80107764:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107769:	e9 ba f0 ff ff       	jmp    80106828 <alltraps>

8010776e <vector225>:
.globl vector225
vector225:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $225
80107770:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107775:	e9 ae f0 ff ff       	jmp    80106828 <alltraps>

8010777a <vector226>:
.globl vector226
vector226:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $226
8010777c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107781:	e9 a2 f0 ff ff       	jmp    80106828 <alltraps>

80107786 <vector227>:
.globl vector227
vector227:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $227
80107788:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010778d:	e9 96 f0 ff ff       	jmp    80106828 <alltraps>

80107792 <vector228>:
.globl vector228
vector228:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $228
80107794:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107799:	e9 8a f0 ff ff       	jmp    80106828 <alltraps>

8010779e <vector229>:
.globl vector229
vector229:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $229
801077a0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801077a5:	e9 7e f0 ff ff       	jmp    80106828 <alltraps>

801077aa <vector230>:
.globl vector230
vector230:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $230
801077ac:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801077b1:	e9 72 f0 ff ff       	jmp    80106828 <alltraps>

801077b6 <vector231>:
.globl vector231
vector231:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $231
801077b8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801077bd:	e9 66 f0 ff ff       	jmp    80106828 <alltraps>

801077c2 <vector232>:
.globl vector232
vector232:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $232
801077c4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801077c9:	e9 5a f0 ff ff       	jmp    80106828 <alltraps>

801077ce <vector233>:
.globl vector233
vector233:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $233
801077d0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801077d5:	e9 4e f0 ff ff       	jmp    80106828 <alltraps>

801077da <vector234>:
.globl vector234
vector234:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $234
801077dc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801077e1:	e9 42 f0 ff ff       	jmp    80106828 <alltraps>

801077e6 <vector235>:
.globl vector235
vector235:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $235
801077e8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801077ed:	e9 36 f0 ff ff       	jmp    80106828 <alltraps>

801077f2 <vector236>:
.globl vector236
vector236:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $236
801077f4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801077f9:	e9 2a f0 ff ff       	jmp    80106828 <alltraps>

801077fe <vector237>:
.globl vector237
vector237:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $237
80107800:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107805:	e9 1e f0 ff ff       	jmp    80106828 <alltraps>

8010780a <vector238>:
.globl vector238
vector238:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $238
8010780c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107811:	e9 12 f0 ff ff       	jmp    80106828 <alltraps>

80107816 <vector239>:
.globl vector239
vector239:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $239
80107818:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010781d:	e9 06 f0 ff ff       	jmp    80106828 <alltraps>

80107822 <vector240>:
.globl vector240
vector240:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $240
80107824:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107829:	e9 fa ef ff ff       	jmp    80106828 <alltraps>

8010782e <vector241>:
.globl vector241
vector241:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $241
80107830:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107835:	e9 ee ef ff ff       	jmp    80106828 <alltraps>

8010783a <vector242>:
.globl vector242
vector242:
  pushl $0
8010783a:	6a 00                	push   $0x0
  pushl $242
8010783c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107841:	e9 e2 ef ff ff       	jmp    80106828 <alltraps>

80107846 <vector243>:
.globl vector243
vector243:
  pushl $0
80107846:	6a 00                	push   $0x0
  pushl $243
80107848:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010784d:	e9 d6 ef ff ff       	jmp    80106828 <alltraps>

80107852 <vector244>:
.globl vector244
vector244:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $244
80107854:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107859:	e9 ca ef ff ff       	jmp    80106828 <alltraps>

8010785e <vector245>:
.globl vector245
vector245:
  pushl $0
8010785e:	6a 00                	push   $0x0
  pushl $245
80107860:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107865:	e9 be ef ff ff       	jmp    80106828 <alltraps>

8010786a <vector246>:
.globl vector246
vector246:
  pushl $0
8010786a:	6a 00                	push   $0x0
  pushl $246
8010786c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107871:	e9 b2 ef ff ff       	jmp    80106828 <alltraps>

80107876 <vector247>:
.globl vector247
vector247:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $247
80107878:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010787d:	e9 a6 ef ff ff       	jmp    80106828 <alltraps>

80107882 <vector248>:
.globl vector248
vector248:
  pushl $0
80107882:	6a 00                	push   $0x0
  pushl $248
80107884:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107889:	e9 9a ef ff ff       	jmp    80106828 <alltraps>

8010788e <vector249>:
.globl vector249
vector249:
  pushl $0
8010788e:	6a 00                	push   $0x0
  pushl $249
80107890:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107895:	e9 8e ef ff ff       	jmp    80106828 <alltraps>

8010789a <vector250>:
.globl vector250
vector250:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $250
8010789c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801078a1:	e9 82 ef ff ff       	jmp    80106828 <alltraps>

801078a6 <vector251>:
.globl vector251
vector251:
  pushl $0
801078a6:	6a 00                	push   $0x0
  pushl $251
801078a8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801078ad:	e9 76 ef ff ff       	jmp    80106828 <alltraps>

801078b2 <vector252>:
.globl vector252
vector252:
  pushl $0
801078b2:	6a 00                	push   $0x0
  pushl $252
801078b4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801078b9:	e9 6a ef ff ff       	jmp    80106828 <alltraps>

801078be <vector253>:
.globl vector253
vector253:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $253
801078c0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801078c5:	e9 5e ef ff ff       	jmp    80106828 <alltraps>

801078ca <vector254>:
.globl vector254
vector254:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $254
801078cc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801078d1:	e9 52 ef ff ff       	jmp    80106828 <alltraps>

801078d6 <vector255>:
.globl vector255
vector255:
  pushl $0
801078d6:	6a 00                	push   $0x0
  pushl $255
801078d8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801078dd:	e9 46 ef ff ff       	jmp    80106828 <alltraps>
	...

801078e4 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801078e4:	55                   	push   %ebp
801078e5:	89 e5                	mov    %esp,%ebp
801078e7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801078ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801078ed:	48                   	dec    %eax
801078ee:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801078f2:	8b 45 08             	mov    0x8(%ebp),%eax
801078f5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801078f9:	8b 45 08             	mov    0x8(%ebp),%eax
801078fc:	c1 e8 10             	shr    $0x10,%eax
801078ff:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107903:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107906:	0f 01 10             	lgdtl  (%eax)
}
80107909:	c9                   	leave  
8010790a:	c3                   	ret    

8010790b <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010790b:	55                   	push   %ebp
8010790c:	89 e5                	mov    %esp,%ebp
8010790e:	83 ec 04             	sub    $0x4,%esp
80107911:	8b 45 08             	mov    0x8(%ebp),%eax
80107914:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107918:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010791b:	0f 00 d8             	ltr    %ax
}
8010791e:	c9                   	leave  
8010791f:	c3                   	ret    

80107920 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107920:	55                   	push   %ebp
80107921:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107923:	8b 45 08             	mov    0x8(%ebp),%eax
80107926:	0f 22 d8             	mov    %eax,%cr3
}
80107929:	5d                   	pop    %ebp
8010792a:	c3                   	ret    

8010792b <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010792b:	55                   	push   %ebp
8010792c:	89 e5                	mov    %esp,%ebp
8010792e:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107931:	e8 0c c9 ff ff       	call   80104242 <cpuid>
80107936:	89 c2                	mov    %eax,%edx
80107938:	89 d0                	mov    %edx,%eax
8010793a:	c1 e0 02             	shl    $0x2,%eax
8010793d:	01 d0                	add    %edx,%eax
8010793f:	01 c0                	add    %eax,%eax
80107941:	01 d0                	add    %edx,%eax
80107943:	c1 e0 04             	shl    $0x4,%eax
80107946:	05 40 4c 11 80       	add    $0x80114c40,%eax
8010794b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010794e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107951:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107963:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796a:	8a 50 7d             	mov    0x7d(%eax),%dl
8010796d:	83 e2 f0             	and    $0xfffffff0,%edx
80107970:	83 ca 0a             	or     $0xa,%edx
80107973:	88 50 7d             	mov    %dl,0x7d(%eax)
80107976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107979:	8a 50 7d             	mov    0x7d(%eax),%dl
8010797c:	83 ca 10             	or     $0x10,%edx
8010797f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107985:	8a 50 7d             	mov    0x7d(%eax),%dl
80107988:	83 e2 9f             	and    $0xffffff9f,%edx
8010798b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010798e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107991:	8a 50 7d             	mov    0x7d(%eax),%dl
80107994:	83 ca 80             	or     $0xffffff80,%edx
80107997:	88 50 7d             	mov    %dl,0x7d(%eax)
8010799a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799d:	8a 50 7e             	mov    0x7e(%eax),%dl
801079a0:	83 ca 0f             	or     $0xf,%edx
801079a3:	88 50 7e             	mov    %dl,0x7e(%eax)
801079a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a9:	8a 50 7e             	mov    0x7e(%eax),%dl
801079ac:	83 e2 ef             	and    $0xffffffef,%edx
801079af:	88 50 7e             	mov    %dl,0x7e(%eax)
801079b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b5:	8a 50 7e             	mov    0x7e(%eax),%dl
801079b8:	83 e2 df             	and    $0xffffffdf,%edx
801079bb:	88 50 7e             	mov    %dl,0x7e(%eax)
801079be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c1:	8a 50 7e             	mov    0x7e(%eax),%dl
801079c4:	83 ca 40             	or     $0x40,%edx
801079c7:	88 50 7e             	mov    %dl,0x7e(%eax)
801079ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cd:	8a 50 7e             	mov    0x7e(%eax),%dl
801079d0:	83 ca 80             	or     $0xffffff80,%edx
801079d3:	88 50 7e             	mov    %dl,0x7e(%eax)
801079d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801079dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801079e7:	ff ff 
801079e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ec:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801079f3:	00 00 
801079f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f8:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801079ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a02:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107a08:	83 e2 f0             	and    $0xfffffff0,%edx
80107a0b:	83 ca 02             	or     $0x2,%edx
80107a0e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a17:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107a1d:	83 ca 10             	or     $0x10,%edx
80107a20:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a29:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107a2f:	83 e2 9f             	and    $0xffffff9f,%edx
80107a32:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3b:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107a41:	83 ca 80             	or     $0xffffff80,%edx
80107a44:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107a53:	83 ca 0f             	or     $0xf,%edx
80107a56:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107a65:	83 e2 ef             	and    $0xffffffef,%edx
80107a68:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a71:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107a77:	83 e2 df             	and    $0xffffffdf,%edx
80107a7a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a83:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107a89:	83 ca 40             	or     $0x40,%edx
80107a8c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a95:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107a9b:	83 ca 80             	or     $0xffffff80,%edx
80107a9e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab1:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107ab8:	ff ff 
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107ac4:	00 00 
80107ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac9:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad3:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107ad9:	83 e2 f0             	and    $0xfffffff0,%edx
80107adc:	83 ca 0a             	or     $0xa,%edx
80107adf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae8:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107aee:	83 ca 10             	or     $0x10,%edx
80107af1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afa:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107b00:	83 ca 60             	or     $0x60,%edx
80107b03:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0c:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107b12:	83 ca 80             	or     $0xffffff80,%edx
80107b15:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107b24:	83 ca 0f             	or     $0xf,%edx
80107b27:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b30:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107b36:	83 e2 ef             	and    $0xffffffef,%edx
80107b39:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b42:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107b48:	83 e2 df             	and    $0xffffffdf,%edx
80107b4b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b54:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107b5a:	83 ca 40             	or     $0x40,%edx
80107b5d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b66:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107b6c:	83 ca 80             	or     $0xffffff80,%edx
80107b6f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b78:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b82:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107b89:	ff ff 
80107b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107b95:	00 00 
80107b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9a:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba4:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107baa:	83 e2 f0             	and    $0xfffffff0,%edx
80107bad:	83 ca 02             	or     $0x2,%edx
80107bb0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb9:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107bbf:	83 ca 10             	or     $0x10,%edx
80107bc2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcb:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107bd1:	83 ca 60             	or     $0x60,%edx
80107bd4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdd:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107be3:	83 ca 80             	or     $0xffffff80,%edx
80107be6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bef:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107bf5:	83 ca 0f             	or     $0xf,%edx
80107bf8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c01:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107c07:	83 e2 ef             	and    $0xffffffef,%edx
80107c0a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107c19:	83 e2 df             	and    $0xffffffdf,%edx
80107c1c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c25:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107c2b:	83 ca 40             	or     $0x40,%edx
80107c2e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c37:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107c3d:	83 ca 80             	or     $0xffffff80,%edx
80107c40:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c49:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c53:	83 c0 70             	add    $0x70,%eax
80107c56:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80107c5d:	00 
80107c5e:	89 04 24             	mov    %eax,(%esp)
80107c61:	e8 7e fc ff ff       	call   801078e4 <lgdt>
}
80107c66:	c9                   	leave  
80107c67:	c3                   	ret    

80107c68 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c68:	55                   	push   %ebp
80107c69:	89 e5                	mov    %esp,%ebp
80107c6b:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c71:	c1 e8 16             	shr    $0x16,%eax
80107c74:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80107c7e:	01 d0                	add    %edx,%eax
80107c80:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c86:	8b 00                	mov    (%eax),%eax
80107c88:	83 e0 01             	and    $0x1,%eax
80107c8b:	85 c0                	test   %eax,%eax
80107c8d:	74 14                	je     80107ca3 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c92:	8b 00                	mov    (%eax),%eax
80107c94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c99:	05 00 00 00 80       	add    $0x80000000,%eax
80107c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ca1:	eb 48                	jmp    80107ceb <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ca3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ca7:	74 0e                	je     80107cb7 <walkpgdir+0x4f>
80107ca9:	e8 9d b0 ff ff       	call   80102d4b <kalloc>
80107cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cb5:	75 07                	jne    80107cbe <walkpgdir+0x56>
      return 0;
80107cb7:	b8 00 00 00 00       	mov    $0x0,%eax
80107cbc:	eb 44                	jmp    80107d02 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107cbe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107cc5:	00 
80107cc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ccd:	00 
80107cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd1:	89 04 24             	mov    %eax,(%esp)
80107cd4:	e8 b1 d4 ff ff       	call   8010518a <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdc:	05 00 00 00 80       	add    $0x80000000,%eax
80107ce1:	83 c8 07             	or     $0x7,%eax
80107ce4:	89 c2                	mov    %eax,%edx
80107ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ce9:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cee:	c1 e8 0c             	shr    $0xc,%eax
80107cf1:	25 ff 03 00 00       	and    $0x3ff,%eax
80107cf6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d00:	01 d0                	add    %edx,%eax
}
80107d02:	c9                   	leave  
80107d03:	c3                   	ret    

80107d04 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107d04:	55                   	push   %ebp
80107d05:	89 e5                	mov    %esp,%ebp
80107d07:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107d15:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d18:	8b 45 10             	mov    0x10(%ebp),%eax
80107d1b:	01 d0                	add    %edx,%eax
80107d1d:	48                   	dec    %eax
80107d1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d26:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107d2d:	00 
80107d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d31:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d35:	8b 45 08             	mov    0x8(%ebp),%eax
80107d38:	89 04 24             	mov    %eax,(%esp)
80107d3b:	e8 28 ff ff ff       	call   80107c68 <walkpgdir>
80107d40:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d43:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d47:	75 07                	jne    80107d50 <mappages+0x4c>
      return -1;
80107d49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d4e:	eb 48                	jmp    80107d98 <mappages+0x94>
    if(*pte & PTE_P)
80107d50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d53:	8b 00                	mov    (%eax),%eax
80107d55:	83 e0 01             	and    $0x1,%eax
80107d58:	85 c0                	test   %eax,%eax
80107d5a:	74 0c                	je     80107d68 <mappages+0x64>
      panic("remap");
80107d5c:	c7 04 24 2c 91 10 80 	movl   $0x8010912c,(%esp)
80107d63:	e8 ec 87 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80107d68:	8b 45 18             	mov    0x18(%ebp),%eax
80107d6b:	0b 45 14             	or     0x14(%ebp),%eax
80107d6e:	83 c8 01             	or     $0x1,%eax
80107d71:	89 c2                	mov    %eax,%edx
80107d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d76:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d7e:	75 08                	jne    80107d88 <mappages+0x84>
      break;
80107d80:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107d81:	b8 00 00 00 00       	mov    $0x0,%eax
80107d86:	eb 10                	jmp    80107d98 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107d88:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107d8f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107d96:	eb 8e                	jmp    80107d26 <mappages+0x22>
  return 0;
}
80107d98:	c9                   	leave  
80107d99:	c3                   	ret    

80107d9a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107d9a:	55                   	push   %ebp
80107d9b:	89 e5                	mov    %esp,%ebp
80107d9d:	53                   	push   %ebx
80107d9e:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107da1:	e8 a5 af ff ff       	call   80102d4b <kalloc>
80107da6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107da9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107dad:	75 0a                	jne    80107db9 <setupkvm+0x1f>
    return 0;
80107daf:	b8 00 00 00 00       	mov    $0x0,%eax
80107db4:	e9 84 00 00 00       	jmp    80107e3d <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80107db9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107dc0:	00 
80107dc1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107dc8:	00 
80107dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dcc:	89 04 24             	mov    %eax,(%esp)
80107dcf:	e8 b6 d3 ff ff       	call   8010518a <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107dd4:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80107ddb:	eb 54                	jmp    80107e31 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de0:	8b 48 0c             	mov    0xc(%eax),%ecx
80107de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de6:	8b 50 04             	mov    0x4(%eax),%edx
80107de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dec:	8b 58 08             	mov    0x8(%eax),%ebx
80107def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df2:	8b 40 04             	mov    0x4(%eax),%eax
80107df5:	29 c3                	sub    %eax,%ebx
80107df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfa:	8b 00                	mov    (%eax),%eax
80107dfc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107e00:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107e04:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107e08:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e0f:	89 04 24             	mov    %eax,(%esp)
80107e12:	e8 ed fe ff ff       	call   80107d04 <mappages>
80107e17:	85 c0                	test   %eax,%eax
80107e19:	79 12                	jns    80107e2d <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e1e:	89 04 24             	mov    %eax,(%esp)
80107e21:	e8 1a 05 00 00       	call   80108340 <freevm>
      return 0;
80107e26:	b8 00 00 00 00       	mov    $0x0,%eax
80107e2b:	eb 10                	jmp    80107e3d <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e2d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e31:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80107e38:	72 a3                	jb     80107ddd <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e3d:	83 c4 34             	add    $0x34,%esp
80107e40:	5b                   	pop    %ebx
80107e41:	5d                   	pop    %ebp
80107e42:	c3                   	ret    

80107e43 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107e43:	55                   	push   %ebp
80107e44:	89 e5                	mov    %esp,%ebp
80107e46:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107e49:	e8 4c ff ff ff       	call   80107d9a <setupkvm>
80107e4e:	a3 64 7a 11 80       	mov    %eax,0x80117a64
  switchkvm();
80107e53:	e8 02 00 00 00       	call   80107e5a <switchkvm>
}
80107e58:	c9                   	leave  
80107e59:	c3                   	ret    

80107e5a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e5a:	55                   	push   %ebp
80107e5b:	89 e5                	mov    %esp,%ebp
80107e5d:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107e60:	a1 64 7a 11 80       	mov    0x80117a64,%eax
80107e65:	05 00 00 00 80       	add    $0x80000000,%eax
80107e6a:	89 04 24             	mov    %eax,(%esp)
80107e6d:	e8 ae fa ff ff       	call   80107920 <lcr3>
}
80107e72:	c9                   	leave  
80107e73:	c3                   	ret    

80107e74 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e74:	55                   	push   %ebp
80107e75:	89 e5                	mov    %esp,%ebp
80107e77:	57                   	push   %edi
80107e78:	56                   	push   %esi
80107e79:	53                   	push   %ebx
80107e7a:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80107e7d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e81:	75 0c                	jne    80107e8f <switchuvm+0x1b>
    panic("switchuvm: no process");
80107e83:	c7 04 24 32 91 10 80 	movl   $0x80109132,(%esp)
80107e8a:	e8 c5 86 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80107e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80107e92:	8b 40 08             	mov    0x8(%eax),%eax
80107e95:	85 c0                	test   %eax,%eax
80107e97:	75 0c                	jne    80107ea5 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80107e99:	c7 04 24 48 91 10 80 	movl   $0x80109148,(%esp)
80107ea0:	e8 af 86 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
80107ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ea8:	8b 40 04             	mov    0x4(%eax),%eax
80107eab:	85 c0                	test   %eax,%eax
80107ead:	75 0c                	jne    80107ebb <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80107eaf:	c7 04 24 5d 91 10 80 	movl   $0x8010915d,(%esp)
80107eb6:	e8 99 86 ff ff       	call   80100554 <panic>

  pushcli();
80107ebb:	e8 c6 d1 ff ff       	call   80105086 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107ec0:	e8 c2 c3 ff ff       	call   80104287 <mycpu>
80107ec5:	89 c3                	mov    %eax,%ebx
80107ec7:	e8 bb c3 ff ff       	call   80104287 <mycpu>
80107ecc:	83 c0 08             	add    $0x8,%eax
80107ecf:	89 c6                	mov    %eax,%esi
80107ed1:	e8 b1 c3 ff ff       	call   80104287 <mycpu>
80107ed6:	83 c0 08             	add    $0x8,%eax
80107ed9:	c1 e8 10             	shr    $0x10,%eax
80107edc:	89 c7                	mov    %eax,%edi
80107ede:	e8 a4 c3 ff ff       	call   80104287 <mycpu>
80107ee3:	83 c0 08             	add    $0x8,%eax
80107ee6:	c1 e8 18             	shr    $0x18,%eax
80107ee9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107ef0:	67 00 
80107ef2:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107ef9:	89 f9                	mov    %edi,%ecx
80107efb:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107f01:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107f07:	83 e2 f0             	and    $0xfffffff0,%edx
80107f0a:	83 ca 09             	or     $0x9,%edx
80107f0d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107f13:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107f19:	83 ca 10             	or     $0x10,%edx
80107f1c:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107f22:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107f28:	83 e2 9f             	and    $0xffffff9f,%edx
80107f2b:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107f31:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80107f37:	83 ca 80             	or     $0xffffff80,%edx
80107f3a:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80107f40:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107f46:	83 e2 f0             	and    $0xfffffff0,%edx
80107f49:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107f4f:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107f55:	83 e2 ef             	and    $0xffffffef,%edx
80107f58:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107f5e:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107f64:	83 e2 df             	and    $0xffffffdf,%edx
80107f67:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107f6d:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107f73:	83 ca 40             	or     $0x40,%edx
80107f76:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107f7c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80107f82:	83 e2 7f             	and    $0x7f,%edx
80107f85:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80107f8b:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107f91:	e8 f1 c2 ff ff       	call   80104287 <mycpu>
80107f96:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80107f9c:	83 e2 ef             	and    $0xffffffef,%edx
80107f9f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107fa5:	e8 dd c2 ff ff       	call   80104287 <mycpu>
80107faa:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107fb0:	e8 d2 c2 ff ff       	call   80104287 <mycpu>
80107fb5:	8b 55 08             	mov    0x8(%ebp),%edx
80107fb8:	8b 52 08             	mov    0x8(%edx),%edx
80107fbb:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107fc1:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107fc4:	e8 be c2 ff ff       	call   80104287 <mycpu>
80107fc9:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107fcf:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80107fd6:	e8 30 f9 ff ff       	call   8010790b <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80107fde:	8b 40 04             	mov    0x4(%eax),%eax
80107fe1:	05 00 00 00 80       	add    $0x80000000,%eax
80107fe6:	89 04 24             	mov    %eax,(%esp)
80107fe9:	e8 32 f9 ff ff       	call   80107920 <lcr3>
  popcli();
80107fee:	e8 dd d0 ff ff       	call   801050d0 <popcli>
}
80107ff3:	83 c4 1c             	add    $0x1c,%esp
80107ff6:	5b                   	pop    %ebx
80107ff7:	5e                   	pop    %esi
80107ff8:	5f                   	pop    %edi
80107ff9:	5d                   	pop    %ebp
80107ffa:	c3                   	ret    

80107ffb <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107ffb:	55                   	push   %ebp
80107ffc:	89 e5                	mov    %esp,%ebp
80107ffe:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108001:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108008:	76 0c                	jbe    80108016 <inituvm+0x1b>
    panic("inituvm: more than a page");
8010800a:	c7 04 24 71 91 10 80 	movl   $0x80109171,(%esp)
80108011:	e8 3e 85 ff ff       	call   80100554 <panic>
  mem = kalloc();
80108016:	e8 30 ad ff ff       	call   80102d4b <kalloc>
8010801b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010801e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108025:	00 
80108026:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010802d:	00 
8010802e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108031:	89 04 24             	mov    %eax,(%esp)
80108034:	e8 51 d1 ff ff       	call   8010518a <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803c:	05 00 00 00 80       	add    $0x80000000,%eax
80108041:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108048:	00 
80108049:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010804d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108054:	00 
80108055:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010805c:	00 
8010805d:	8b 45 08             	mov    0x8(%ebp),%eax
80108060:	89 04 24             	mov    %eax,(%esp)
80108063:	e8 9c fc ff ff       	call   80107d04 <mappages>
  memmove(mem, init, sz);
80108068:	8b 45 10             	mov    0x10(%ebp),%eax
8010806b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010806f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108072:	89 44 24 04          	mov    %eax,0x4(%esp)
80108076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108079:	89 04 24             	mov    %eax,(%esp)
8010807c:	e8 d2 d1 ff ff       	call   80105253 <memmove>
}
80108081:	c9                   	leave  
80108082:	c3                   	ret    

80108083 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108083:	55                   	push   %ebp
80108084:	89 e5                	mov    %esp,%ebp
80108086:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108089:	8b 45 0c             	mov    0xc(%ebp),%eax
8010808c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108091:	85 c0                	test   %eax,%eax
80108093:	74 0c                	je     801080a1 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108095:	c7 04 24 8c 91 10 80 	movl   $0x8010918c,(%esp)
8010809c:	e8 b3 84 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801080a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080a8:	e9 a6 00 00 00       	jmp    80108153 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801080ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801080b3:	01 d0                	add    %edx,%eax
801080b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080bc:	00 
801080bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801080c1:	8b 45 08             	mov    0x8(%ebp),%eax
801080c4:	89 04 24             	mov    %eax,(%esp)
801080c7:	e8 9c fb ff ff       	call   80107c68 <walkpgdir>
801080cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080cf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080d3:	75 0c                	jne    801080e1 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801080d5:	c7 04 24 af 91 10 80 	movl   $0x801091af,(%esp)
801080dc:	e8 73 84 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
801080e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080e4:	8b 00                	mov    (%eax),%eax
801080e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801080ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f1:	8b 55 18             	mov    0x18(%ebp),%edx
801080f4:	29 c2                	sub    %eax,%edx
801080f6:	89 d0                	mov    %edx,%eax
801080f8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801080fd:	77 0f                	ja     8010810e <loaduvm+0x8b>
      n = sz - i;
801080ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108102:	8b 55 18             	mov    0x18(%ebp),%edx
80108105:	29 c2                	sub    %eax,%edx
80108107:	89 d0                	mov    %edx,%eax
80108109:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010810c:	eb 07                	jmp    80108115 <loaduvm+0x92>
    else
      n = PGSIZE;
8010810e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108118:	8b 55 14             	mov    0x14(%ebp),%edx
8010811b:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010811e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108121:	05 00 00 00 80       	add    $0x80000000,%eax
80108126:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108129:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010812d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108131:	89 44 24 04          	mov    %eax,0x4(%esp)
80108135:	8b 45 10             	mov    0x10(%ebp),%eax
80108138:	89 04 24             	mov    %eax,(%esp)
8010813b:	e8 71 9e ff ff       	call   80101fb1 <readi>
80108140:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108143:	74 07                	je     8010814c <loaduvm+0xc9>
      return -1;
80108145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010814a:	eb 18                	jmp    80108164 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010814c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108156:	3b 45 18             	cmp    0x18(%ebp),%eax
80108159:	0f 82 4e ff ff ff    	jb     801080ad <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010815f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108164:	c9                   	leave  
80108165:	c3                   	ret    

80108166 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108166:	55                   	push   %ebp
80108167:	89 e5                	mov    %esp,%ebp
80108169:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010816c:	8b 45 10             	mov    0x10(%ebp),%eax
8010816f:	85 c0                	test   %eax,%eax
80108171:	79 0a                	jns    8010817d <allocuvm+0x17>
    return 0;
80108173:	b8 00 00 00 00       	mov    $0x0,%eax
80108178:	e9 fd 00 00 00       	jmp    8010827a <allocuvm+0x114>
  if(newsz < oldsz)
8010817d:	8b 45 10             	mov    0x10(%ebp),%eax
80108180:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108183:	73 08                	jae    8010818d <allocuvm+0x27>
    return oldsz;
80108185:	8b 45 0c             	mov    0xc(%ebp),%eax
80108188:	e9 ed 00 00 00       	jmp    8010827a <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
8010818d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108190:	05 ff 0f 00 00       	add    $0xfff,%eax
80108195:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010819a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010819d:	e9 c9 00 00 00       	jmp    8010826b <allocuvm+0x105>
    mem = kalloc();
801081a2:	e8 a4 ab ff ff       	call   80102d4b <kalloc>
801081a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801081aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081ae:	75 2f                	jne    801081df <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
801081b0:	c7 04 24 cd 91 10 80 	movl   $0x801091cd,(%esp)
801081b7:	e8 05 82 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801081bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801081bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801081c3:	8b 45 10             	mov    0x10(%ebp),%eax
801081c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801081ca:	8b 45 08             	mov    0x8(%ebp),%eax
801081cd:	89 04 24             	mov    %eax,(%esp)
801081d0:	e8 a7 00 00 00       	call   8010827c <deallocuvm>
      return 0;
801081d5:	b8 00 00 00 00       	mov    $0x0,%eax
801081da:	e9 9b 00 00 00       	jmp    8010827a <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
801081df:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081e6:	00 
801081e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081ee:	00 
801081ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f2:	89 04 24             	mov    %eax,(%esp)
801081f5:	e8 90 cf ff ff       	call   8010518a <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801081fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081fd:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108206:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010820d:	00 
8010820e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108212:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108219:	00 
8010821a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010821e:	8b 45 08             	mov    0x8(%ebp),%eax
80108221:	89 04 24             	mov    %eax,(%esp)
80108224:	e8 db fa ff ff       	call   80107d04 <mappages>
80108229:	85 c0                	test   %eax,%eax
8010822b:	79 37                	jns    80108264 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
8010822d:	c7 04 24 e5 91 10 80 	movl   $0x801091e5,(%esp)
80108234:	e8 88 81 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108239:	8b 45 0c             	mov    0xc(%ebp),%eax
8010823c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108240:	8b 45 10             	mov    0x10(%ebp),%eax
80108243:	89 44 24 04          	mov    %eax,0x4(%esp)
80108247:	8b 45 08             	mov    0x8(%ebp),%eax
8010824a:	89 04 24             	mov    %eax,(%esp)
8010824d:	e8 2a 00 00 00       	call   8010827c <deallocuvm>
      kfree(mem);
80108252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108255:	89 04 24             	mov    %eax,(%esp)
80108258:	e8 58 aa ff ff       	call   80102cb5 <kfree>
      return 0;
8010825d:	b8 00 00 00 00       	mov    $0x0,%eax
80108262:	eb 16                	jmp    8010827a <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108264:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010826b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826e:	3b 45 10             	cmp    0x10(%ebp),%eax
80108271:	0f 82 2b ff ff ff    	jb     801081a2 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108277:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010827a:	c9                   	leave  
8010827b:	c3                   	ret    

8010827c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010827c:	55                   	push   %ebp
8010827d:	89 e5                	mov    %esp,%ebp
8010827f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108282:	8b 45 10             	mov    0x10(%ebp),%eax
80108285:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108288:	72 08                	jb     80108292 <deallocuvm+0x16>
    return oldsz;
8010828a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010828d:	e9 ac 00 00 00       	jmp    8010833e <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108292:	8b 45 10             	mov    0x10(%ebp),%eax
80108295:	05 ff 0f 00 00       	add    $0xfff,%eax
8010829a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010829f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801082a2:	e9 88 00 00 00       	jmp    8010832f <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801082a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082b1:	00 
801082b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801082b6:	8b 45 08             	mov    0x8(%ebp),%eax
801082b9:	89 04 24             	mov    %eax,(%esp)
801082bc:	e8 a7 f9 ff ff       	call   80107c68 <walkpgdir>
801082c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801082c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082c8:	75 14                	jne    801082de <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801082ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082cd:	c1 e8 16             	shr    $0x16,%eax
801082d0:	40                   	inc    %eax
801082d1:	c1 e0 16             	shl    $0x16,%eax
801082d4:	2d 00 10 00 00       	sub    $0x1000,%eax
801082d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082dc:	eb 4a                	jmp    80108328 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
801082de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082e1:	8b 00                	mov    (%eax),%eax
801082e3:	83 e0 01             	and    $0x1,%eax
801082e6:	85 c0                	test   %eax,%eax
801082e8:	74 3e                	je     80108328 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
801082ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082ed:	8b 00                	mov    (%eax),%eax
801082ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801082f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082fb:	75 0c                	jne    80108309 <deallocuvm+0x8d>
        panic("kfree");
801082fd:	c7 04 24 01 92 10 80 	movl   $0x80109201,(%esp)
80108304:	e8 4b 82 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108309:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010830c:	05 00 00 00 80       	add    $0x80000000,%eax
80108311:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108314:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108317:	89 04 24             	mov    %eax,(%esp)
8010831a:	e8 96 a9 ff ff       	call   80102cb5 <kfree>
      *pte = 0;
8010831f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108322:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108328:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010832f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108332:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108335:	0f 82 6c ff ff ff    	jb     801082a7 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010833b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010833e:	c9                   	leave  
8010833f:	c3                   	ret    

80108340 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108340:	55                   	push   %ebp
80108341:	89 e5                	mov    %esp,%ebp
80108343:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108346:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010834a:	75 0c                	jne    80108358 <freevm+0x18>
    panic("freevm: no pgdir");
8010834c:	c7 04 24 07 92 10 80 	movl   $0x80109207,(%esp)
80108353:	e8 fc 81 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108358:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010835f:	00 
80108360:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108367:	80 
80108368:	8b 45 08             	mov    0x8(%ebp),%eax
8010836b:	89 04 24             	mov    %eax,(%esp)
8010836e:	e8 09 ff ff ff       	call   8010827c <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108373:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010837a:	eb 44                	jmp    801083c0 <freevm+0x80>
    if(pgdir[i] & PTE_P){
8010837c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108386:	8b 45 08             	mov    0x8(%ebp),%eax
80108389:	01 d0                	add    %edx,%eax
8010838b:	8b 00                	mov    (%eax),%eax
8010838d:	83 e0 01             	and    $0x1,%eax
80108390:	85 c0                	test   %eax,%eax
80108392:	74 29                	je     801083bd <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108397:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010839e:	8b 45 08             	mov    0x8(%ebp),%eax
801083a1:	01 d0                	add    %edx,%eax
801083a3:	8b 00                	mov    (%eax),%eax
801083a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083aa:	05 00 00 00 80       	add    $0x80000000,%eax
801083af:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801083b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b5:	89 04 24             	mov    %eax,(%esp)
801083b8:	e8 f8 a8 ff ff       	call   80102cb5 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801083bd:	ff 45 f4             	incl   -0xc(%ebp)
801083c0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801083c7:	76 b3                	jbe    8010837c <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801083c9:	8b 45 08             	mov    0x8(%ebp),%eax
801083cc:	89 04 24             	mov    %eax,(%esp)
801083cf:	e8 e1 a8 ff ff       	call   80102cb5 <kfree>
}
801083d4:	c9                   	leave  
801083d5:	c3                   	ret    

801083d6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801083d6:	55                   	push   %ebp
801083d7:	89 e5                	mov    %esp,%ebp
801083d9:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083e3:	00 
801083e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801083e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801083eb:	8b 45 08             	mov    0x8(%ebp),%eax
801083ee:	89 04 24             	mov    %eax,(%esp)
801083f1:	e8 72 f8 ff ff       	call   80107c68 <walkpgdir>
801083f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801083f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801083fd:	75 0c                	jne    8010840b <clearpteu+0x35>
    panic("clearpteu");
801083ff:	c7 04 24 18 92 10 80 	movl   $0x80109218,(%esp)
80108406:	e8 49 81 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
8010840b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840e:	8b 00                	mov    (%eax),%eax
80108410:	83 e0 fb             	and    $0xfffffffb,%eax
80108413:	89 c2                	mov    %eax,%edx
80108415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108418:	89 10                	mov    %edx,(%eax)
}
8010841a:	c9                   	leave  
8010841b:	c3                   	ret    

8010841c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010841c:	55                   	push   %ebp
8010841d:	89 e5                	mov    %esp,%ebp
8010841f:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108422:	e8 73 f9 ff ff       	call   80107d9a <setupkvm>
80108427:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010842a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010842e:	75 0a                	jne    8010843a <copyuvm+0x1e>
    return 0;
80108430:	b8 00 00 00 00       	mov    $0x0,%eax
80108435:	e9 f8 00 00 00       	jmp    80108532 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
8010843a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108441:	e9 cb 00 00 00       	jmp    80108511 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108449:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108450:	00 
80108451:	89 44 24 04          	mov    %eax,0x4(%esp)
80108455:	8b 45 08             	mov    0x8(%ebp),%eax
80108458:	89 04 24             	mov    %eax,(%esp)
8010845b:	e8 08 f8 ff ff       	call   80107c68 <walkpgdir>
80108460:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108463:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108467:	75 0c                	jne    80108475 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108469:	c7 04 24 22 92 10 80 	movl   $0x80109222,(%esp)
80108470:	e8 df 80 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108475:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108478:	8b 00                	mov    (%eax),%eax
8010847a:	83 e0 01             	and    $0x1,%eax
8010847d:	85 c0                	test   %eax,%eax
8010847f:	75 0c                	jne    8010848d <copyuvm+0x71>
      panic("copyuvm: page not present");
80108481:	c7 04 24 3c 92 10 80 	movl   $0x8010923c,(%esp)
80108488:	e8 c7 80 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
8010848d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108490:	8b 00                	mov    (%eax),%eax
80108492:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108497:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010849a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010849d:	8b 00                	mov    (%eax),%eax
8010849f:	25 ff 0f 00 00       	and    $0xfff,%eax
801084a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801084a7:	e8 9f a8 ff ff       	call   80102d4b <kalloc>
801084ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
801084af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801084b3:	75 02                	jne    801084b7 <copyuvm+0x9b>
      goto bad;
801084b5:	eb 6b                	jmp    80108522 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
801084b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084ba:	05 00 00 00 80       	add    $0x80000000,%eax
801084bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084c6:	00 
801084c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801084cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084ce:	89 04 24             	mov    %eax,(%esp)
801084d1:	e8 7d cd ff ff       	call   80105253 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801084d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801084d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084dc:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801084e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e5:	89 54 24 10          	mov    %edx,0x10(%esp)
801084e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801084ed:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084f4:	00 
801084f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801084f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084fc:	89 04 24             	mov    %eax,(%esp)
801084ff:	e8 00 f8 ff ff       	call   80107d04 <mappages>
80108504:	85 c0                	test   %eax,%eax
80108506:	79 02                	jns    8010850a <copyuvm+0xee>
      goto bad;
80108508:	eb 18                	jmp    80108522 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010850a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108514:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108517:	0f 82 29 ff ff ff    	jb     80108446 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
8010851d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108520:	eb 10                	jmp    80108532 <copyuvm+0x116>

bad:
  freevm(d);
80108522:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108525:	89 04 24             	mov    %eax,(%esp)
80108528:	e8 13 fe ff ff       	call   80108340 <freevm>
  return 0;
8010852d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108532:	c9                   	leave  
80108533:	c3                   	ret    

80108534 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108534:	55                   	push   %ebp
80108535:	89 e5                	mov    %esp,%ebp
80108537:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010853a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108541:	00 
80108542:	8b 45 0c             	mov    0xc(%ebp),%eax
80108545:	89 44 24 04          	mov    %eax,0x4(%esp)
80108549:	8b 45 08             	mov    0x8(%ebp),%eax
8010854c:	89 04 24             	mov    %eax,(%esp)
8010854f:	e8 14 f7 ff ff       	call   80107c68 <walkpgdir>
80108554:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855a:	8b 00                	mov    (%eax),%eax
8010855c:	83 e0 01             	and    $0x1,%eax
8010855f:	85 c0                	test   %eax,%eax
80108561:	75 07                	jne    8010856a <uva2ka+0x36>
    return 0;
80108563:	b8 00 00 00 00       	mov    $0x0,%eax
80108568:	eb 22                	jmp    8010858c <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010856a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856d:	8b 00                	mov    (%eax),%eax
8010856f:	83 e0 04             	and    $0x4,%eax
80108572:	85 c0                	test   %eax,%eax
80108574:	75 07                	jne    8010857d <uva2ka+0x49>
    return 0;
80108576:	b8 00 00 00 00       	mov    $0x0,%eax
8010857b:	eb 0f                	jmp    8010858c <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
8010857d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108580:	8b 00                	mov    (%eax),%eax
80108582:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108587:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010858c:	c9                   	leave  
8010858d:	c3                   	ret    

8010858e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010858e:	55                   	push   %ebp
8010858f:	89 e5                	mov    %esp,%ebp
80108591:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108594:	8b 45 10             	mov    0x10(%ebp),%eax
80108597:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010859a:	e9 87 00 00 00       	jmp    80108626 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
8010859f:	8b 45 0c             	mov    0xc(%ebp),%eax
801085a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801085aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801085b1:	8b 45 08             	mov    0x8(%ebp),%eax
801085b4:	89 04 24             	mov    %eax,(%esp)
801085b7:	e8 78 ff ff ff       	call   80108534 <uva2ka>
801085bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801085bf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801085c3:	75 07                	jne    801085cc <copyout+0x3e>
      return -1;
801085c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085ca:	eb 69                	jmp    80108635 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801085cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801085cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
801085d2:	29 c2                	sub    %eax,%edx
801085d4:	89 d0                	mov    %edx,%eax
801085d6:	05 00 10 00 00       	add    $0x1000,%eax
801085db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801085de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085e1:	3b 45 14             	cmp    0x14(%ebp),%eax
801085e4:	76 06                	jbe    801085ec <copyout+0x5e>
      n = len;
801085e6:	8b 45 14             	mov    0x14(%ebp),%eax
801085e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801085ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801085f2:	29 c2                	sub    %eax,%edx
801085f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085f7:	01 c2                	add    %eax,%edx
801085f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085fc:	89 44 24 08          	mov    %eax,0x8(%esp)
80108600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108603:	89 44 24 04          	mov    %eax,0x4(%esp)
80108607:	89 14 24             	mov    %edx,(%esp)
8010860a:	e8 44 cc ff ff       	call   80105253 <memmove>
    len -= n;
8010860f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108612:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108615:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108618:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010861b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010861e:	05 00 10 00 00       	add    $0x1000,%eax
80108623:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108626:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010862a:	0f 85 6f ff ff ff    	jne    8010859f <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108630:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108635:	c9                   	leave  
80108636:	c3                   	ret    
	...

80108638 <strcpy>:
#define NULL ((void*)0)
#define MAX_CONTAINERS 4

struct container containers[MAX_CONTAINERS];

char* strcpy(char *s, char *t){
80108638:	55                   	push   %ebp
80108639:	89 e5                	mov    %esp,%ebp
8010863b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010863e:	8b 45 08             	mov    0x8(%ebp),%eax
80108641:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80108644:	90                   	nop
80108645:	8b 45 08             	mov    0x8(%ebp),%eax
80108648:	8d 50 01             	lea    0x1(%eax),%edx
8010864b:	89 55 08             	mov    %edx,0x8(%ebp)
8010864e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108651:	8d 4a 01             	lea    0x1(%edx),%ecx
80108654:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80108657:	8a 12                	mov    (%edx),%dl
80108659:	88 10                	mov    %dl,(%eax)
8010865b:	8a 00                	mov    (%eax),%al
8010865d:	84 c0                	test   %al,%al
8010865f:	75 e4                	jne    80108645 <strcpy+0xd>
    ;
  return os;
80108661:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80108664:	c9                   	leave  
80108665:	c3                   	ret    

80108666 <strcmp>:

int
strcmp(const char *p, const char *q)
{
80108666:	55                   	push   %ebp
80108667:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80108669:	eb 06                	jmp    80108671 <strcmp+0xb>
    p++, q++;
8010866b:	ff 45 08             	incl   0x8(%ebp)
8010866e:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
80108671:	8b 45 08             	mov    0x8(%ebp),%eax
80108674:	8a 00                	mov    (%eax),%al
80108676:	84 c0                	test   %al,%al
80108678:	74 0e                	je     80108688 <strcmp+0x22>
8010867a:	8b 45 08             	mov    0x8(%ebp),%eax
8010867d:	8a 10                	mov    (%eax),%dl
8010867f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108682:	8a 00                	mov    (%eax),%al
80108684:	38 c2                	cmp    %al,%dl
80108686:	74 e3                	je     8010866b <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80108688:	8b 45 08             	mov    0x8(%ebp),%eax
8010868b:	8a 00                	mov    (%eax),%al
8010868d:	0f b6 d0             	movzbl %al,%edx
80108690:	8b 45 0c             	mov    0xc(%ebp),%eax
80108693:	8a 00                	mov    (%eax),%al
80108695:	0f b6 c0             	movzbl %al,%eax
80108698:	29 c2                	sub    %eax,%edx
8010869a:	89 d0                	mov    %edx,%eax
}
8010869c:	5d                   	pop    %ebp
8010869d:	c3                   	ret    

8010869e <get_name>:

void get_name(char* name, int vc_num){
8010869e:	55                   	push   %ebp
8010869f:	89 e5                	mov    %esp,%ebp
801086a1:	57                   	push   %edi
801086a2:	56                   	push   %esi
801086a3:	53                   	push   %ebx
801086a4:	83 ec 48             	sub    $0x48,%esp
	struct container x = containers[vc_num];
801086a7:	8b 55 0c             	mov    0xc(%ebp),%edx
801086aa:	89 d0                	mov    %edx,%eax
801086ac:	01 c0                	add    %eax,%eax
801086ae:	01 d0                	add    %edx,%eax
801086b0:	01 c0                	add    %eax,%eax
801086b2:	01 d0                	add    %edx,%eax
801086b4:	c1 e0 03             	shl    $0x3,%eax
801086b7:	05 80 7a 11 80       	add    $0x80117a80,%eax
801086bc:	8d 55 bc             	lea    -0x44(%ebp),%edx
801086bf:	89 c3                	mov    %eax,%ebx
801086c1:	b8 0e 00 00 00       	mov    $0xe,%eax
801086c6:	89 d7                	mov    %edx,%edi
801086c8:	89 de                	mov    %ebx,%esi
801086ca:	89 c1                	mov    %eax,%ecx
801086cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	strcpy(name, x.name);
801086ce:	8d 45 bc             	lea    -0x44(%ebp),%eax
801086d1:	83 c0 18             	add    $0x18,%eax
801086d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801086d8:	8b 45 08             	mov    0x8(%ebp),%eax
801086db:	89 04 24             	mov    %eax,(%esp)
801086de:	e8 55 ff ff ff       	call   80108638 <strcpy>
}
801086e3:	83 c4 48             	add    $0x48,%esp
801086e6:	5b                   	pop    %ebx
801086e7:	5e                   	pop    %esi
801086e8:	5f                   	pop    %edi
801086e9:	5d                   	pop    %ebp
801086ea:	c3                   	ret    

801086eb <is_full>:

int is_full(){
801086eb:	55                   	push   %ebp
801086ec:	89 e5                	mov    %esp,%ebp
801086ee:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801086f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086f8:	eb 2f                	jmp    80108729 <is_full+0x3e>
		if(strlen(containers[i].name) == 0){
801086fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086fd:	89 d0                	mov    %edx,%eax
801086ff:	01 c0                	add    %eax,%eax
80108701:	01 d0                	add    %edx,%eax
80108703:	01 c0                	add    %eax,%eax
80108705:	01 d0                	add    %edx,%eax
80108707:	c1 e0 03             	shl    $0x3,%eax
8010870a:	83 c0 10             	add    $0x10,%eax
8010870d:	05 80 7a 11 80       	add    $0x80117a80,%eax
80108712:	83 c0 08             	add    $0x8,%eax
80108715:	89 04 24             	mov    %eax,(%esp)
80108718:	e8 c0 cc ff ff       	call   801053dd <strlen>
8010871d:	85 c0                	test   %eax,%eax
8010871f:	75 05                	jne    80108726 <is_full+0x3b>
			return i;
80108721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108724:	eb 0e                	jmp    80108734 <is_full+0x49>
	strcpy(name, x.name);
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108726:	ff 45 f4             	incl   -0xc(%ebp)
80108729:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
8010872d:	7e cb                	jle    801086fa <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
8010872f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108734:	c9                   	leave  
80108735:	c3                   	ret    

80108736 <find>:

int find(char* name){
80108736:	55                   	push   %ebp
80108737:	89 e5                	mov    %esp,%ebp
80108739:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
8010873c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108743:	eb 36                	jmp    8010877b <find+0x45>
		if(containers[i].name == NULL){
			continue;
		}
		if(strcmp(name, containers[i].name) == 0){
80108745:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108748:	89 d0                	mov    %edx,%eax
8010874a:	01 c0                	add    %eax,%eax
8010874c:	01 d0                	add    %edx,%eax
8010874e:	01 c0                	add    %eax,%eax
80108750:	01 d0                	add    %edx,%eax
80108752:	c1 e0 03             	shl    $0x3,%eax
80108755:	83 c0 10             	add    $0x10,%eax
80108758:	05 80 7a 11 80       	add    $0x80117a80,%eax
8010875d:	83 c0 08             	add    $0x8,%eax
80108760:	89 44 24 04          	mov    %eax,0x4(%esp)
80108764:	8b 45 08             	mov    0x8(%ebp),%eax
80108767:	89 04 24             	mov    %eax,(%esp)
8010876a:	e8 f7 fe ff ff       	call   80108666 <strcmp>
8010876f:	85 c0                	test   %eax,%eax
80108771:	75 05                	jne    80108778 <find+0x42>
			return i;
80108773:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108776:	eb 0e                	jmp    80108786 <find+0x50>
	return -1;
}

int find(char* name){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80108778:	ff 45 fc             	incl   -0x4(%ebp)
8010877b:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
8010877f:	7e c4                	jle    80108745 <find+0xf>
		}
		if(strcmp(name, containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80108781:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108786:	c9                   	leave  
80108787:	c3                   	ret    

80108788 <get_max_proc>:

int get_max_proc(int vc_num){
80108788:	55                   	push   %ebp
80108789:	89 e5                	mov    %esp,%ebp
8010878b:	57                   	push   %edi
8010878c:	56                   	push   %esi
8010878d:	53                   	push   %ebx
8010878e:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108791:	8b 55 08             	mov    0x8(%ebp),%edx
80108794:	89 d0                	mov    %edx,%eax
80108796:	01 c0                	add    %eax,%eax
80108798:	01 d0                	add    %edx,%eax
8010879a:	01 c0                	add    %eax,%eax
8010879c:	01 d0                	add    %edx,%eax
8010879e:	c1 e0 03             	shl    $0x3,%eax
801087a1:	05 80 7a 11 80       	add    $0x80117a80,%eax
801087a6:	8d 55 bc             	lea    -0x44(%ebp),%edx
801087a9:	89 c3                	mov    %eax,%ebx
801087ab:	b8 0e 00 00 00       	mov    $0xe,%eax
801087b0:	89 d7                	mov    %edx,%edi
801087b2:	89 de                	mov    %ebx,%esi
801087b4:	89 c1                	mov    %eax,%ecx
801087b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
801087b8:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
801087bb:	83 c4 40             	add    $0x40,%esp
801087be:	5b                   	pop    %ebx
801087bf:	5e                   	pop    %esi
801087c0:	5f                   	pop    %edi
801087c1:	5d                   	pop    %ebp
801087c2:	c3                   	ret    

801087c3 <get_max_mem>:

int get_max_mem(int vc_num){
801087c3:	55                   	push   %ebp
801087c4:	89 e5                	mov    %esp,%ebp
801087c6:	57                   	push   %edi
801087c7:	56                   	push   %esi
801087c8:	53                   	push   %ebx
801087c9:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801087cc:	8b 55 08             	mov    0x8(%ebp),%edx
801087cf:	89 d0                	mov    %edx,%eax
801087d1:	01 c0                	add    %eax,%eax
801087d3:	01 d0                	add    %edx,%eax
801087d5:	01 c0                	add    %eax,%eax
801087d7:	01 d0                	add    %edx,%eax
801087d9:	c1 e0 03             	shl    $0x3,%eax
801087dc:	05 80 7a 11 80       	add    $0x80117a80,%eax
801087e1:	8d 55 bc             	lea    -0x44(%ebp),%edx
801087e4:	89 c3                	mov    %eax,%ebx
801087e6:	b8 0e 00 00 00       	mov    $0xe,%eax
801087eb:	89 d7                	mov    %edx,%edi
801087ed:	89 de                	mov    %ebx,%esi
801087ef:	89 c1                	mov    %eax,%ecx
801087f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
801087f3:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
801087f6:	83 c4 40             	add    $0x40,%esp
801087f9:	5b                   	pop    %ebx
801087fa:	5e                   	pop    %esi
801087fb:	5f                   	pop    %edi
801087fc:	5d                   	pop    %ebp
801087fd:	c3                   	ret    

801087fe <get_max_disk>:

int get_max_disk(int vc_num){
801087fe:	55                   	push   %ebp
801087ff:	89 e5                	mov    %esp,%ebp
80108801:	57                   	push   %edi
80108802:	56                   	push   %esi
80108803:	53                   	push   %ebx
80108804:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108807:	8b 55 08             	mov    0x8(%ebp),%edx
8010880a:	89 d0                	mov    %edx,%eax
8010880c:	01 c0                	add    %eax,%eax
8010880e:	01 d0                	add    %edx,%eax
80108810:	01 c0                	add    %eax,%eax
80108812:	01 d0                	add    %edx,%eax
80108814:	c1 e0 03             	shl    $0x3,%eax
80108817:	05 80 7a 11 80       	add    $0x80117a80,%eax
8010881c:	8d 55 bc             	lea    -0x44(%ebp),%edx
8010881f:	89 c3                	mov    %eax,%ebx
80108821:	b8 0e 00 00 00       	mov    $0xe,%eax
80108826:	89 d7                	mov    %edx,%edi
80108828:	89 de                	mov    %ebx,%esi
8010882a:	89 c1                	mov    %eax,%ecx
8010882c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
8010882e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
80108831:	83 c4 40             	add    $0x40,%esp
80108834:	5b                   	pop    %ebx
80108835:	5e                   	pop    %esi
80108836:	5f                   	pop    %edi
80108837:	5d                   	pop    %ebp
80108838:	c3                   	ret    

80108839 <get_curr_proc>:

int get_curr_proc(int vc_num){
80108839:	55                   	push   %ebp
8010883a:	89 e5                	mov    %esp,%ebp
8010883c:	57                   	push   %edi
8010883d:	56                   	push   %esi
8010883e:	53                   	push   %ebx
8010883f:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80108842:	8b 55 08             	mov    0x8(%ebp),%edx
80108845:	89 d0                	mov    %edx,%eax
80108847:	01 c0                	add    %eax,%eax
80108849:	01 d0                	add    %edx,%eax
8010884b:	01 c0                	add    %eax,%eax
8010884d:	01 d0                	add    %edx,%eax
8010884f:	c1 e0 03             	shl    $0x3,%eax
80108852:	05 80 7a 11 80       	add    $0x80117a80,%eax
80108857:	8d 55 bc             	lea    -0x44(%ebp),%edx
8010885a:	89 c3                	mov    %eax,%ebx
8010885c:	b8 0e 00 00 00       	mov    $0xe,%eax
80108861:	89 d7                	mov    %edx,%edi
80108863:	89 de                	mov    %ebx,%esi
80108865:	89 c1                	mov    %eax,%ecx
80108867:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80108869:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
8010886c:	83 c4 40             	add    $0x40,%esp
8010886f:	5b                   	pop    %ebx
80108870:	5e                   	pop    %esi
80108871:	5f                   	pop    %edi
80108872:	5d                   	pop    %ebp
80108873:	c3                   	ret    

80108874 <get_curr_mem>:

int get_curr_mem(int vc_num){
80108874:	55                   	push   %ebp
80108875:	89 e5                	mov    %esp,%ebp
80108877:	57                   	push   %edi
80108878:	56                   	push   %esi
80108879:	53                   	push   %ebx
8010887a:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010887d:	8b 55 08             	mov    0x8(%ebp),%edx
80108880:	89 d0                	mov    %edx,%eax
80108882:	01 c0                	add    %eax,%eax
80108884:	01 d0                	add    %edx,%eax
80108886:	01 c0                	add    %eax,%eax
80108888:	01 d0                	add    %edx,%eax
8010888a:	c1 e0 03             	shl    $0x3,%eax
8010888d:	05 80 7a 11 80       	add    $0x80117a80,%eax
80108892:	8d 55 bc             	lea    -0x44(%ebp),%edx
80108895:	89 c3                	mov    %eax,%ebx
80108897:	b8 0e 00 00 00       	mov    $0xe,%eax
8010889c:	89 d7                	mov    %edx,%edi
8010889e:	89 de                	mov    %ebx,%esi
801088a0:	89 c1                	mov    %eax,%ecx
801088a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_mem; 
801088a4:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
801088a7:	83 c4 40             	add    $0x40,%esp
801088aa:	5b                   	pop    %ebx
801088ab:	5e                   	pop    %esi
801088ac:	5f                   	pop    %edi
801088ad:	5d                   	pop    %ebp
801088ae:	c3                   	ret    

801088af <get_curr_disk>:

int get_curr_disk(int vc_num){
801088af:	55                   	push   %ebp
801088b0:	89 e5                	mov    %esp,%ebp
801088b2:	57                   	push   %edi
801088b3:	56                   	push   %esi
801088b4:	53                   	push   %ebx
801088b5:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801088b8:	8b 55 08             	mov    0x8(%ebp),%edx
801088bb:	89 d0                	mov    %edx,%eax
801088bd:	01 c0                	add    %eax,%eax
801088bf:	01 d0                	add    %edx,%eax
801088c1:	01 c0                	add    %eax,%eax
801088c3:	01 d0                	add    %edx,%eax
801088c5:	c1 e0 03             	shl    $0x3,%eax
801088c8:	05 80 7a 11 80       	add    $0x80117a80,%eax
801088cd:	8d 55 bc             	lea    -0x44(%ebp),%edx
801088d0:	89 c3                	mov    %eax,%ebx
801088d2:	b8 0e 00 00 00       	mov    $0xe,%eax
801088d7:	89 d7                	mov    %edx,%edi
801088d9:	89 de                	mov    %ebx,%esi
801088db:	89 c1                	mov    %eax,%ecx
801088dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
801088df:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
801088e2:	83 c4 40             	add    $0x40,%esp
801088e5:	5b                   	pop    %ebx
801088e6:	5e                   	pop    %esi
801088e7:	5f                   	pop    %edi
801088e8:	5d                   	pop    %ebp
801088e9:	c3                   	ret    

801088ea <set_name>:

void set_name(char* name, int vc_num){
801088ea:	55                   	push   %ebp
801088eb:	89 e5                	mov    %esp,%ebp
801088ed:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
801088f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801088f3:	89 d0                	mov    %edx,%eax
801088f5:	01 c0                	add    %eax,%eax
801088f7:	01 d0                	add    %edx,%eax
801088f9:	01 c0                	add    %eax,%eax
801088fb:	01 d0                	add    %edx,%eax
801088fd:	c1 e0 03             	shl    $0x3,%eax
80108900:	83 c0 10             	add    $0x10,%eax
80108903:	05 80 7a 11 80       	add    $0x80117a80,%eax
80108908:	8d 50 08             	lea    0x8(%eax),%edx
8010890b:	8b 45 08             	mov    0x8(%ebp),%eax
8010890e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108912:	89 14 24             	mov    %edx,(%esp)
80108915:	e8 1e fd ff ff       	call   80108638 <strcpy>
}
8010891a:	c9                   	leave  
8010891b:	c3                   	ret    

8010891c <set_max_mem>:

void set_max_mem(int mem, int vc_num){
8010891c:	55                   	push   %ebp
8010891d:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
8010891f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108922:	89 d0                	mov    %edx,%eax
80108924:	01 c0                	add    %eax,%eax
80108926:	01 d0                	add    %edx,%eax
80108928:	01 c0                	add    %eax,%eax
8010892a:	01 d0                	add    %edx,%eax
8010892c:	c1 e0 03             	shl    $0x3,%eax
8010892f:	8d 90 80 7a 11 80    	lea    -0x7fee8580(%eax),%edx
80108935:	8b 45 08             	mov    0x8(%ebp),%eax
80108938:	89 02                	mov    %eax,(%edx)
}
8010893a:	5d                   	pop    %ebp
8010893b:	c3                   	ret    

8010893c <set_max_disk>:

void set_max_disk(int disk, int vc_num){
8010893c:	55                   	push   %ebp
8010893d:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
8010893f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108942:	89 d0                	mov    %edx,%eax
80108944:	01 c0                	add    %eax,%eax
80108946:	01 d0                	add    %edx,%eax
80108948:	01 c0                	add    %eax,%eax
8010894a:	01 d0                	add    %edx,%eax
8010894c:	c1 e0 03             	shl    $0x3,%eax
8010894f:	8d 90 80 7a 11 80    	lea    -0x7fee8580(%eax),%edx
80108955:	8b 45 08             	mov    0x8(%ebp),%eax
80108958:	89 42 08             	mov    %eax,0x8(%edx)
}
8010895b:	5d                   	pop    %ebp
8010895c:	c3                   	ret    

8010895d <set_max_proc>:

void set_max_proc(int procs, int vc_num){
8010895d:	55                   	push   %ebp
8010895e:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80108960:	8b 55 0c             	mov    0xc(%ebp),%edx
80108963:	89 d0                	mov    %edx,%eax
80108965:	01 c0                	add    %eax,%eax
80108967:	01 d0                	add    %edx,%eax
80108969:	01 c0                	add    %eax,%eax
8010896b:	01 d0                	add    %edx,%eax
8010896d:	c1 e0 03             	shl    $0x3,%eax
80108970:	8d 90 80 7a 11 80    	lea    -0x7fee8580(%eax),%edx
80108976:	8b 45 08             	mov    0x8(%ebp),%eax
80108979:	89 42 04             	mov    %eax,0x4(%edx)
}
8010897c:	5d                   	pop    %ebp
8010897d:	c3                   	ret    

8010897e <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
8010897e:	55                   	push   %ebp
8010897f:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = mem;	
80108981:	8b 55 0c             	mov    0xc(%ebp),%edx
80108984:	89 d0                	mov    %edx,%eax
80108986:	01 c0                	add    %eax,%eax
80108988:	01 d0                	add    %edx,%eax
8010898a:	01 c0                	add    %eax,%eax
8010898c:	01 d0                	add    %edx,%eax
8010898e:	c1 e0 03             	shl    $0x3,%eax
80108991:	8d 90 80 7a 11 80    	lea    -0x7fee8580(%eax),%edx
80108997:	8b 45 08             	mov    0x8(%ebp),%eax
8010899a:	89 42 0c             	mov    %eax,0xc(%edx)
}
8010899d:	5d                   	pop    %ebp
8010899e:	c3                   	ret    

8010899f <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
8010899f:	55                   	push   %ebp
801089a0:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_disk += disk;
801089a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801089a5:	89 d0                	mov    %edx,%eax
801089a7:	01 c0                	add    %eax,%eax
801089a9:	01 d0                	add    %edx,%eax
801089ab:	01 c0                	add    %eax,%eax
801089ad:	01 d0                	add    %edx,%eax
801089af:	c1 e0 03             	shl    $0x3,%eax
801089b2:	05 90 7a 11 80       	add    $0x80117a90,%eax
801089b7:	8b 50 04             	mov    0x4(%eax),%edx
801089ba:	8b 45 08             	mov    0x8(%ebp),%eax
801089bd:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801089c0:	8b 55 0c             	mov    0xc(%ebp),%edx
801089c3:	89 d0                	mov    %edx,%eax
801089c5:	01 c0                	add    %eax,%eax
801089c7:	01 d0                	add    %edx,%eax
801089c9:	01 c0                	add    %eax,%eax
801089cb:	01 d0                	add    %edx,%eax
801089cd:	c1 e0 03             	shl    $0x3,%eax
801089d0:	05 90 7a 11 80       	add    $0x80117a90,%eax
801089d5:	89 48 04             	mov    %ecx,0x4(%eax)
}
801089d8:	5d                   	pop    %ebp
801089d9:	c3                   	ret    

801089da <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
801089da:	55                   	push   %ebp
801089db:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_proc = procs;	
801089dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801089e0:	89 d0                	mov    %edx,%eax
801089e2:	01 c0                	add    %eax,%eax
801089e4:	01 d0                	add    %edx,%eax
801089e6:	01 c0                	add    %eax,%eax
801089e8:	01 d0                	add    %edx,%eax
801089ea:	c1 e0 03             	shl    $0x3,%eax
801089ed:	8d 90 90 7a 11 80    	lea    -0x7fee8570(%eax),%edx
801089f3:	8b 45 08             	mov    0x8(%ebp),%eax
801089f6:	89 02                	mov    %eax,(%edx)
}
801089f8:	5d                   	pop    %ebp
801089f9:	c3                   	ret    

801089fa <container_init>:

void container_init(){
801089fa:	55                   	push   %ebp
801089fb:	89 e5                	mov    %esp,%ebp
801089fd:	83 ec 18             	sub    $0x18,%esp

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80108a00:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80108a07:	e9 d4 00 00 00       	jmp    80108ae0 <container_init+0xe6>
		strcpy(containers[i].name, "");
80108a0c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108a0f:	89 d0                	mov    %edx,%eax
80108a11:	01 c0                	add    %eax,%eax
80108a13:	01 d0                	add    %edx,%eax
80108a15:	01 c0                	add    %eax,%eax
80108a17:	01 d0                	add    %edx,%eax
80108a19:	c1 e0 03             	shl    $0x3,%eax
80108a1c:	83 c0 10             	add    $0x10,%eax
80108a1f:	05 80 7a 11 80       	add    $0x80117a80,%eax
80108a24:	83 c0 08             	add    $0x8,%eax
80108a27:	c7 44 24 04 56 92 10 	movl   $0x80109256,0x4(%esp)
80108a2e:	80 
80108a2f:	89 04 24             	mov    %eax,(%esp)
80108a32:	e8 01 fc ff ff       	call   80108638 <strcpy>
		containers[i].max_proc = 4;
80108a37:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108a3a:	89 d0                	mov    %edx,%eax
80108a3c:	01 c0                	add    %eax,%eax
80108a3e:	01 d0                	add    %edx,%eax
80108a40:	01 c0                	add    %eax,%eax
80108a42:	01 d0                	add    %edx,%eax
80108a44:	c1 e0 03             	shl    $0x3,%eax
80108a47:	05 80 7a 11 80       	add    $0x80117a80,%eax
80108a4c:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
80108a53:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108a56:	89 d0                	mov    %edx,%eax
80108a58:	01 c0                	add    %eax,%eax
80108a5a:	01 d0                	add    %edx,%eax
80108a5c:	01 c0                	add    %eax,%eax
80108a5e:	01 d0                	add    %edx,%eax
80108a60:	c1 e0 03             	shl    $0x3,%eax
80108a63:	05 80 7a 11 80       	add    $0x80117a80,%eax
80108a68:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 100;
80108a6f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108a72:	89 d0                	mov    %edx,%eax
80108a74:	01 c0                	add    %eax,%eax
80108a76:	01 d0                	add    %edx,%eax
80108a78:	01 c0                	add    %eax,%eax
80108a7a:	01 d0                	add    %edx,%eax
80108a7c:	c1 e0 03             	shl    $0x3,%eax
80108a7f:	05 80 7a 11 80       	add    $0x80117a80,%eax
80108a84:	c7 00 64 00 00 00    	movl   $0x64,(%eax)
		containers[i].curr_proc = 1;
80108a8a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108a8d:	89 d0                	mov    %edx,%eax
80108a8f:	01 c0                	add    %eax,%eax
80108a91:	01 d0                	add    %edx,%eax
80108a93:	01 c0                	add    %eax,%eax
80108a95:	01 d0                	add    %edx,%eax
80108a97:	c1 e0 03             	shl    $0x3,%eax
80108a9a:	05 90 7a 11 80       	add    $0x80117a90,%eax
80108a9f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
80108aa5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108aa8:	89 d0                	mov    %edx,%eax
80108aaa:	01 c0                	add    %eax,%eax
80108aac:	01 d0                	add    %edx,%eax
80108aae:	01 c0                	add    %eax,%eax
80108ab0:	01 d0                	add    %edx,%eax
80108ab2:	c1 e0 03             	shl    $0x3,%eax
80108ab5:	05 90 7a 11 80       	add    $0x80117a90,%eax
80108aba:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
80108ac1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80108ac4:	89 d0                	mov    %edx,%eax
80108ac6:	01 c0                	add    %eax,%eax
80108ac8:	01 d0                	add    %edx,%eax
80108aca:	01 c0                	add    %eax,%eax
80108acc:	01 d0                	add    %edx,%eax
80108ace:	c1 e0 03             	shl    $0x3,%eax
80108ad1:	05 80 7a 11 80       	add    $0x80117a80,%eax
80108ad6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

void container_init(){

	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80108add:	ff 45 fc             	incl   -0x4(%ebp)
80108ae0:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80108ae4:	0f 8e 22 ff ff ff    	jle    80108a0c <container_init+0x12>
		containers[i].max_mem = 100;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
80108aea:	c9                   	leave  
80108aeb:	c3                   	ret    
